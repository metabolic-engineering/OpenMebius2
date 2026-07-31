classdef NextLabelExperimentWorkflow
    % NEXTLABELEXPERIMENTWORKFLOW
    % Builds tracer candidates and evaluates their confidence intervals.

    properties (SetAccess = private)
        SubstrateEMUFactory
        MDVPredictor
    end

    methods

        function obj = NextLabelExperimentWorkflow(options)

            arguments
                options.SubstrateEMUFactory = ...
                    openmebius.mfa.SubstrateEMUFactory()
                options.MDVPredictor = ...
                    openmebius.mfa.SteadyStateMDVPredictor()
            end

            obj.SubstrateEMUFactory = options.SubstrateEMUFactory;
            obj.MDVPredictor = options.MDVPredictor;

        end

        function result = run( ...
                obj, model, experiments, experimentList, settings, ...
                bestFlux, options)

            arguments
                obj (1, 1) openmebius.mfa.NextLabelExperimentWorkflow
                model
                experiments
                experimentList
                settings (1, 1) openmebius.mfa ...
                    .NextLabelExperimentSettings
                bestFlux (:, 1) double
                options.ConfidenceIntervalFunction ...
                    (1, 1) function_handle
                options.PatternCompleted ...
                    (1, 1) function_handle = @(~, ~, ~) []
                options.MessageReporter ...
                    (1, 1) function_handle = @(~, ~) []
                options.CancellationRequested ...
                    (1, 1) function_handle = @() false
            end

            report = options.MessageReporter;
            report("info", "Suggesting next flux experiment...");
            baseEMUs = cell(numel(experimentList), 1);

            for i = 1:numel(experimentList)
                baseEMUs{i} = obj.SubstrateEMUFactory.fromExperiment( ...
                    model, experiments, experimentList(i));
            end

            patterns = cell(0, 1);
            lowerBounds = cell(0, 1);
            upperBounds = cell(0, 1);
            outputs = cell(0, 1);
            isCanceled = false;
            patternCount = settings.patternCount();

            for iPattern = 1:patternCount
                pattern = settings.patternAt(iPattern);

                if ~settings.isCompletePattern(iPattern)
                    continue
                end

                report( ...
                    "info", ...
                    "Evaluating pattern " + string(iPattern) + "/" + ...
                    string(patternCount) + "...");
                report( ...
                    "info", ...
                "Generating EMU model for the pattern...");
                candidateEMU = obj.SubstrateEMUFactory.fromPattern( ...
                    model, experiments, cellstr(pattern));
                candidateEMUs = [baseEMUs; {candidateEMU}];

                if logical(options.CancellationRequested())
                    isCanceled = true;
                    break
                end

                candidateMDV = obj.MDVPredictor.predictLinearized( ...
                    model, bestFlux, candidateEMUs);
                [candidateLB, candidateUB, candidateOutput] = ...
                    options.ConfidenceIntervalFunction( ...
                    candidateMDV, candidateEMUs);
                options.PatternCompleted( ...
                    pattern, candidateLB, candidateUB);
                patterns{end + 1, 1} = pattern; %#ok<AGROW>
                lowerBounds{end + 1, 1} = candidateLB; %#ok<AGROW>
                upperBounds{end + 1, 1} = candidateUB; %#ok<AGROW>
                outputs{end + 1, 1} = candidateOutput; %#ok<AGROW>

                if logical(options.CancellationRequested())
                    isCanceled = true;
                    break
                end

            end

            if isCanceled
                report( ...
                    "info", ...
                "Next flux experiment suggestion canceled.");
            else
                report("info", "Next flux experiment suggested.");
            end

            result = ...
                openmebius.mfa.NextLabelExperimentWorkflowResult( ...
                Patterns = patterns, ...
                LowerBounds = lowerBounds, ...
                UpperBounds = upperBounds, ...
                Outputs = outputs, ...
                IsCanceled = isCanceled);

        end

    end

end
