classdef MFAInheritedResultWorkflow
    % Rebuilds runtime inputs without generating seeds or optimizing fluxes.
    properties (SetAccess = private)
        InputPreparationWorkflow
        ProblemFactory
        SubstrateEMUFactory
        InstationaryInputFactory
    end
    methods
        function obj = MFAInheritedResultWorkflow(options)
            arguments
                options.InputPreparationWorkflow = openmebius.application.analysis.MFAInputPreparationWorkflow()
                options.ProblemFactory = openmebius.mfa.MFAProblemFactory()
                options.SubstrateEMUFactory = openmebius.mfa.SubstrateEMUFactory()
                options.InstationaryInputFactory = openmebius.mfa.InstationaryInputFactory()
            end
            obj.InputPreparationWorkflow = options.InputPreparationWorkflow;
            obj.ProblemFactory = options.ProblemFactory;
            obj.SubstrateEMUFactory = options.SubstrateEMUFactory;
            obj.InstationaryInputFactory = options.InstationaryInputFactory;
        end

        function result = run(obj, model, experiments, experimentList, ...
                settings, context, session, resultID, data, options)
            arguments
                obj
                model
                experiments
                experimentList
                settings
                context
                session
                resultID
                data struct
                options.MessageReporter function_handle = @(~, ~) []
                options.CancellationRequested function_handle = @() false
            end
            input = obj.InputPreparationWorkflow.run(model, experiments, ...
                experimentList, settings.InputPreparationSettings, ...
                MessageReporter = options.MessageReporter);
            cleanup = onCleanup(@() input.restoreModel());
            if ~input.IsValid
                error('OpenMebius2:Inheritance:InvalidInputs', '%s', input.ErrorMessage);
            end
            experimental = input.ExperimentalData;
            if ~obj.sameMeasurements(experimental.ExperimentalMDV, data.MDVExp) || ...
                    ~isequal(string(experimental.FragmentLabels(:)), string(data.MDVFragList(:))) || ...
                    ~isequal(logical(experimental.FragmentMask), logical(data.MDVFragMask))
                error('OpenMebius2:Inheritance:ChangedInputs', ...
                    'The fragments or measurements differ from the inherited result.');
            end
            obj.validateModel(model.getModelTable(), data.model, ...
                {'modelID', 'modelReaction', 'modelTransition', 'modelIndependent'});
            if isfield(data.model, 'modelRevID')
                obj.validateModel(model.getModelTableRev(), data.model, ...
                    {'modelRevID', 'modelReactionRev', 'modelTransitionRev', 'modelIndependentRev'});
            end
            if options.CancellationRequested()
                result = openmebius.application.analysis.MFAFluxDistributionResult( ...
                    InputPreparation = input, IsCanceled = true);
                return
            end
            % Keep the original numerical inputs after allowing only the
            % round-off introduced by an Excel save/load cycle.
            experimental = openmebius.mfa.MFAExperimentalData( ...
                ExperimentalMDV = data.MDVExp, FragmentLabels = data.MDVFragList, ...
                FragmentMask = data.MDVFragMask);
            context.setExperimentalData(experimental);
            context.setBounds(data.fluxVariability.fluxLB, data.fluxVariability.fluxUB);
            context.setRightHandSide(data.initialFlux.rhs(:, 1));
            freeConstraints = strings(0, 1);
            if input.GrowthRateFree
                freeConstraints = "biomass";
            end
            problem = obj.ProblemFactory.create(model.getS(), model.getSType(), ...
                context.RightHandSide, context.LowerBounds, context.UpperBounds, ...
                FreeConstraintIDs = freeConstraints);
            context.setInitialResult(openmebius.mfa.InitialFluxWorkflowResult.success( ...
                Problem = problem, Fluxes = data.initialFlux.flux, ...
                RightHandSides = data.initialFlux.rhs, ObjectiveValues = data.initialFlux.RSS));
            emus = cell(numel(experimentList), 1);
            for index = 1:numel(experimentList)
                emus{index} = obj.SubstrateEMUFactory.fromExperiment( ...
                    model, experiments, experimentList(index));
            end
            context.setSubstrateEMUs(emus);
            if settings.IterationSettings.AnalysisMode.isInstationary()
                context.setInstationaryInput(obj.InstationaryInputFactory.create( ...
                    model, settings.InstationaryInputSpecification));
            end
            order = reshape(double(data.RSSIndex), 1, []);
            options.MessageReporter('info', sprintf( ...
                'Restoring inherited optimization in memory (0/%d)...', numel(order)));
            iterations = cell(1, numel(order));
            fluxes = zeros(numel(context.LowerBounds), numel(order));
            mdvs = cell(1, numel(order));
            for index = 1:numel(order)
                if options.CancellationRequested()
                    result = openmebius.application.analysis.MFAFluxDistributionResult( ...
                        InputPreparation = input, IsCanceled = true);
                    return
                end
                value = data.fluxResult.(sprintf('iteration%04d', order(index)));
                iterations{index} = openmebius.mfa.MFAIterationResult( ...
                    IndependentValues = [], Flux = value.flux, MDV = value.MDV, ...
                    ObjectiveValue = value.RSS, ExitFlag = value.exitflag);
                fluxes(:, index) = value.flux;
                mdvs{index} = experimental.arrangeMDV(value.MDV);
                if mod(index, 500) == 0 || index == numel(order)
                    options.MessageReporter('info', sprintf( ...
                        'Restoring inherited optimization in memory (%d/%d)...', index, numel(order)));
                end
            end
            workflow = openmebius.mfa.MFAWorkflowResult( ...
                ObjectiveValues = reshape(data.RSS, 1, []), Fluxes = fluxes, ...
                MDVs = cat(3, mdvs{:}), Order = order, IterationResults = iterations);
            isCanceled = session.restoreOptimization(data, resultID, ...
                ProgressReporter = @(current, total) options.MessageReporter('info', sprintf( ...
                'Saving inherited optimization results (%d/%d)...', current, total)), ...
                CancellationRequested = options.CancellationRequested);
            if isCanceled
                result = openmebius.application.analysis.MFAFluxDistributionResult( ...
                    InputPreparation = input, IsCanceled = true);
                return
            end
            context.setWorkflowResult(workflow);
            options.MessageReporter('info', ...
                'Inherited optimization restored; starting optional calculations.');
            result = openmebius.application.analysis.MFAFluxDistributionResult( ...
                InputPreparation = input, WorkflowResult = workflow, ...
                MinimumObjective = data.RSS(1));
        end
    end
    methods (Static, Access = private)
        function equal = sameMeasurements(actual, expected)
            equal = isequal(size(actual), size(expected));
            if ~equal
                return
            end
            tolerance = 32 * eps(max(1, max(abs(actual), abs(expected))));
            equal = all(actual == expected | (isnan(actual) & isnan(expected)) | ...
                abs(actual - expected) <= tolerance, 'all');
        end

        function validateModel(modelTable, saved, fields)
            actual = {string(modelTable.Properties.RowNames(:)), ...
                string(modelTable.Reaction(:)), string(modelTable.Transition(:)), ...
                logical(modelTable.Independent(:))};
            for index = 1:numel(fields)
                expected = saved.(fields{index})(:);
                if index == 4
                    expected = logical(expected);
                else
                    expected = string(expected);
                end
                if ~isequal(actual{index}, expected)
                    error('OpenMebius2:Inheritance:ChangedInputs', ...
                        'The reaction definitions, atom transitions, or independent variables differ from the inherited result.');
                end
            end
        end
    end
end
