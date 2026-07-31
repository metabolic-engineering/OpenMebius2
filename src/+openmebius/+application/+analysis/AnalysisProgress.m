classdef AnalysisProgress < handle
    % ANALYSISPROGRESS Typed in-memory completion state for MFA phases.

    properties (SetAccess = private)
        InitialFluxCompleted (1, 1) logical = false
        FluxDistributionCompleted (1, 1) logical = false
        ConfidenceIntervalCompleted (1, 1) logical = false
    end

    methods

        function markInitialFluxCompleted(obj)
            obj.InitialFluxCompleted = true;
        end

        function markFluxDistributionCompleted(obj)
            obj.FluxDistributionCompleted = true;
        end

        function markConfidenceIntervalCompleted(obj)
            obj.ConfidenceIntervalCompleted = true;
        end

        function vector = toStorageVector(obj)
            vector = double([ ...
                                 obj.InitialFluxCompleted, ...
                                 obj.FluxDistributionCompleted, ...
                                 obj.ConfidenceIntervalCompleted, ...
                                 false]);
        end

    end

end
