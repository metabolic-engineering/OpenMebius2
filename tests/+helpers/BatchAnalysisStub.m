classdef BatchAnalysisStub < handle

    events
        GeneralMsg
        FluxResult
    end

    properties
        isCanceled (1, 1) logical = false
        isError (1, 1) logical = false
        Config (1, 1) struct
        FailurePhase (1, 1) string = ""
        Calls (1, :) string = strings(1, 0)
        FinalizeCount (1, 1) double = 0
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
            notify(obj, 'GeneralMsg');
            notify(obj, 'FluxResult');

        end

        function suggestNextFluxExperiment(obj)

            obj.Calls(end + 1) = "suggest";
            obj.applyOutcome("suggest");

        end

        function calculateConfidenceInterval(obj)

            obj.Calls(end + 1) = "ci";
            obj.applyOutcome("ci");

        end

        function config = getConfig(obj)

            config = obj.Config;

        end

        function finalizeRun(obj)

            obj.FinalizeCount = obj.FinalizeCount + 1;

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
