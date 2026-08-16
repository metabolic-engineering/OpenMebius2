classdef BatchAnalysisStub < handle

    properties
        isCanceled (1, 1) logical = false
        isError (1, 1) logical = false
        Config (1, 1) struct
        FailurePhase (1, 1) string = ""
        Calls (1, :) string = strings(1, 0)
        FinalizeCount (1, 1) double = 0
        MessageReporter (1, 1) function_handle = @(~) []
        ResultReporter (1, 1) function_handle = @(~) []
        ProgressReporter (1, 1) function_handle = @(~, ~) []
    end

    methods

        function obj = BatchAnalysisStub(config, failurePhase)

            arguments
                config (1, 1) struct
                failurePhase (1, 1) string = ""
            end

            obj.Config = config;
            obj.FailurePhase = failurePhase;

        end

        function calculateFluxDistribution(obj)

            obj.Calls(end + 1) = "flux";
            obj.applyOutcome("flux");
            obj.MessageReporter( ...
                openmebius.core.notification.Message( ...
                    "Flux calculation updated.", "info"));
            obj.ResultReporter(struct("ID", "stub-result"));

        end

        function suggestNextFluxExperiment(obj)

            obj.Calls(end + 1) = "suggest";
            obj.applyOutcome("suggest");

        end

        function calculateConfidenceInterval(obj)

            obj.Calls(end + 1) = "ci";
            obj.applyOutcome("ci");
            obj.ProgressReporter(1, 4);

        end

        function finalizeRun(obj)

            obj.FinalizeCount = obj.FinalizeCount + 1;

        end

        function configureReporters(obj, varargin)

            for index = 1:numel(varargin) - 1
                value = varargin{index};

                if ~(ischar(value) || isstring(value))
                    continue
                end

                name = string(value);

                if name == "MessageReporter"
                    obj.MessageReporter = varargin{index + 1};
                elseif name == "ResultReporter"
                    obj.ResultReporter = varargin{index + 1};
                elseif name == "ProgressReporter"
                    obj.ProgressReporter = varargin{index + 1};
                end
            end

        end

    end

    methods (Access = private)

        function applyOutcome(obj, phase)

            if obj.FailurePhase == "error-" + phase
                obj.isError = true;
            elseif obj.FailurePhase == "cancel-" + phase
                obj.isCanceled = true;
            end

        end

    end

end
