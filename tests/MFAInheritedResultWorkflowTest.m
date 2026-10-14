classdef MFAInheritedResultWorkflowTest < matlab.unittest.TestCase
    methods (TestMethodSetup)
        function setup(~)
            addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'src'));
        end
    end
    methods (Test)
        function restoresOrderedFluxesAndInitialCandidatesWithoutOptimization(testCase)
            [workflow, inputWorkflow, context, session, settings, data] = testCase.fixture();
            result = workflow.run(helpers.InheritedModelStub(), [], 1, ...
                settings, context, session, 'bat_new', data);
            testCase.verifyFalse(result.IsError);
            testCase.verifyEqual(inputWorkflow.CallCount, 1);
            testCase.verifyEqual(context.InitialResult.RightHandSides, data.initialFlux.rhs);
            testCase.verifyEqual(context.WorkflowResult.Fluxes, [5, 5; 0.6, 0.4]);
            testCase.verifyEqual(context.WorkflowResult.ObjectiveValues, [1, 2]);
            testCase.verifyEqual(context.WorkflowResult.Order, [2, 1]);
            testCase.verifyEqual(context.SubstrateEMUs, {1});
            testCase.verifyTrue(session.Progress.FluxDistributionCompleted);
            testCase.verifyFalse(session.Progress.ConfidenceIntervalCompleted);
            testCase.verifyEqual(session.Result.ID, 'bat_new');
            testCase.verifyEqual(session.Result.fluxResult0002.flux, [5; 0.6]);
            testCase.verifyEqual(session.Result.fluxResult0001.time, int32(125));
        end

        function changedMeasurementsCannotReuseOptimization(testCase)
            [workflow, ~, context, session, settings, data] = testCase.fixture();
            data.MDVExp(1) = 0.5;
            testCase.verifyError(@() workflow.run(helpers.InheritedModelStub(), [], 1, ...
                settings, context, session, 'bat_new', data), 'OpenMebius2:Inheritance:ChangedInputs');
            testCase.verifyFalse(session.Progress.FluxDistributionCompleted);
        end

        function workbookRoundoffUsesOriginalMeasurements(testCase)
            [workflow, ~, context, session, settings, data] = testCase.fixture();
            data.MDVExp(1) = data.MDVExp(1) + eps;
            result = workflow.run(helpers.InheritedModelStub(), [], 1, ...
                settings, context, session, 'bat_new', data);
            testCase.verifyFalse(result.IsError);
            testCase.verifyEqual(context.ExperimentalData.ExperimentalMDV, data.MDVExp);
        end

        function measurementChangesBeyondRoundoffAreRejected(testCase)
            [workflow, ~, context, session, settings, data] = testCase.fixture();
            data.MDVExp(1) = data.MDVExp(1) + 1e-10;
            testCase.verifyError(@() workflow.run(helpers.InheritedModelStub(), [], 1, ...
                settings, context, session, 'bat_new', data), 'OpenMebius2:Inheritance:ChangedInputs');
        end

        function canceledRestoreLeavesResultUnfinished(testCase)
            [workflow, ~, context, session, settings, data] = testCase.fixture();
            result = workflow.run(helpers.InheritedModelStub(), [], 1, ...
                settings, context, session, 'bat_new', data, CancellationRequested = @() true);
            testCase.verifyTrue(result.IsCanceled);
            testCase.verifyFalse(session.Progress.FluxDistributionCompleted);
        end

        function cancelDuringExportStopsBeforeOptionalCalculations(testCase)
            [workflow, ~, context, ~, settings, data] = testCase.fixture();
            fixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture());
            file = fullfile(fixture.Folder, 'inherited.h5');
            session = openmebius.application.analysis.MFAResultSession( ...
                Coordinator = openmebius.infrastructure.result.MFAResultCoordinator(HDF5FilePath = file));
            cancel = false;
            result = workflow.run(helpers.InheritedModelStub(), [], 1, ...
                settings, context, session, 'bat_new', data, ...
                MessageReporter = @report, CancellationRequested = @cancellationRequested);
            testCase.verifyTrue(result.IsCanceled);
            testCase.verifyFalse(session.Progress.FluxDistributionCompleted);
            testCase.verifyEqual(h5read(file, '/status'), int8([0 0 0 0]));
            testCase.verifyEmpty(context.WorkflowResult);

            function report(~, message)
                if contains(message, 'Saving inherited optimization results (2/2)')
                    cancel = true;
                end
            end

            function value = cancellationRequested()
                value = cancel;
            end
        end

        function failedExportDoesNotMarkOptimizationComplete(testCase)
            [workflow, ~, context, ~, settings, data] = testCase.fixture();
            fixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture());
            file = fullfile(fixture.Folder, 'missing-folder', 'inherited.h5');
            session = openmebius.application.analysis.MFAResultSession( ...
                Coordinator = openmebius.infrastructure.result.MFAResultCoordinator(HDF5FilePath = file));
            testCase.verifyError(@() workflow.run(helpers.InheritedModelStub(), [], 1, ...
                settings, context, session, 'bat_new', data), 'OpenMebius2:Inheritance:WriteFailed');
            testCase.verifyFalse(session.Progress.FluxDistributionCompleted);
            testCase.verifyEmpty(context.WorkflowResult);
        end

        function changedModelContentsCannotReuseOptimization(testCase)
            for field = ["modelReaction", "modelTransition", "modelIndependent"]
                [workflow, ~, context, session, settings, data] = testCase.fixture();
                if field == "modelIndependent"
                    data.model.(field)(1) = 1;
                else
                    data.model.(field)(1) = "changed";
                end
                testCase.verifyError(@() workflow.run(helpers.InheritedModelStub(), [], 1, ...
                    settings, context, session, 'bat_new', data), 'OpenMebius2:Inheritance:ChangedInputs');
                testCase.verifyFalse(session.Progress.FluxDistributionCompleted);
            end
        end

        function changedReverseModelCannotReuseOptimization(testCase)
            [workflow, ~, context, session, settings, data] = testCase.fixture();
            data.model.modelRevID = data.model.modelID;
            data.model.modelReactionRev = data.model.modelReaction;
            data.model.modelTransitionRev = data.model.modelTransition;
            data.model.modelIndependentRev = data.model.modelIndependent;
            data.model.modelTransitionRev(1) = "changed";
            testCase.verifyError(@() workflow.run(helpers.InheritedModelStub(), [], 1, ...
                settings, context, session, 'bat_new', data), 'OpenMebius2:Inheritance:ChangedInputs');
        end
    end
    methods (Static, Access = private)
        function [workflow, inputWorkflow, context, session, settings, data] = fixture()
            data = helpers.inheritedOptimizationData();
            experimental = openmebius.mfa.MFAExperimentalData( ...
                ExperimentalMDV = data.MDVExp, FragmentLabels = data.MDVFragList, ...
                FragmentMask = data.MDVFragMask);
            input = openmebius.application.analysis.MFAInputPreparationResult( ...
                IsValid = true, ExperimentalData = experimental, ...
                GrowthRate = 0.1, SubstrateList = "A", Efflux = 10, ...
                EffluxStandardDeviation = 1, EffluxFree = false);
            inputWorkflow = helpers.WorkflowResultStub(input);
            workflow = openmebius.application.analysis.MFAInheritedResultWorkflow( ...
                InputPreparationWorkflow = inputWorkflow, ...
                SubstrateEMUFactory = helpers.SubstrateEMUFactoryStub());
            context = openmebius.application.analysis.MFAAnalysisRunContext();
            session = openmebius.application.analysis.MFAResultSession( ...
                Coordinator = openmebius.infrastructure.result.MFAResultCoordinator(IsExport = false));
            settings = openmebius.application.analysis.MFAAnalysisSettings();
        end
    end
end
