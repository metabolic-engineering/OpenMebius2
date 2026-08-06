classdef MFAInputPreparationResult
    % MFAINPUTPREPARATIONRESULT
    % Immutable validated MFA inputs and temporary model-session owner.

    properties (SetAccess = private)
        IsValid (1, 1) logical = false
        FailureStage (1, 1) string = ""
        ErrorMessage (1, 1) string = ""
        GrowthRate (1, 1) double = NaN
        GrowthRateStandardDeviation (1, 1) double = NaN
        GrowthRateFree (1, 1) logical = false
        SubstrateList (:, 1) string = strings(0, 1)
        Efflux (:, 1) double = zeros(0, 1)
        EffluxStandardDeviation (:, 1) double = zeros(0, 1)
        EffluxFree (:, 1) logical = false(0, 1)
        ExperimentalData = []
        EffluxFreeSession = []
    end

    methods

        function obj = MFAInputPreparationResult(options)

            arguments
                options.IsValid (1, 1) logical
                options.FailureStage (1, 1) string {mustBeMember( ...
                                                        options.FailureStage, ["", "efflux", "mdv"])} = ""
                options.ErrorMessage (1, 1) string = ""
                options.GrowthRate (1, 1) double = NaN
                options.GrowthRateStandardDeviation (1, 1) double = NaN
                options.GrowthRateFree (1, 1) logical = false
                options.SubstrateList = strings(0, 1)
                options.Efflux (:, 1) double = zeros(0, 1)
                options.EffluxStandardDeviation (:, 1) double = ...
                    zeros(0, 1)
                options.EffluxFree (:, 1) logical = false(0, 1)
                options.ExperimentalData = []
                options.EffluxFreeSession = []
            end

            hasFailure = options.FailureStage ~= "" && ...
                strlength(options.ErrorMessage) > 0;

            if options.IsValid == hasFailure
                error( ...
                    "OpenMebius2:MFAInputPreparation:" + ...
                    "InconsistentResult", ...
                    "Successful input preparation cannot contain a " + ...
                "failure, and failed preparation must describe one.");
            end

            obj.IsValid = options.IsValid;
            obj.FailureStage = options.FailureStage;
            obj.ErrorMessage = options.ErrorMessage;
            obj.GrowthRate = options.GrowthRate;
            obj.GrowthRateStandardDeviation = ...
                options.GrowthRateStandardDeviation;
            obj.GrowthRateFree = options.GrowthRateFree;
            obj.SubstrateList = string(options.SubstrateList(:));
            obj.Efflux = options.Efflux;
            obj.EffluxStandardDeviation = ...
                options.EffluxStandardDeviation;
            obj.EffluxFree = options.EffluxFree;
            obj.ExperimentalData = options.ExperimentalData;
            obj.EffluxFreeSession = options.EffluxFreeSession;

        end % constructor

        function restoreModel(obj)

            if ~isempty(obj.EffluxFreeSession)
                obj.EffluxFreeSession.restore();
            end

        end % restoreModel

    end % methods

end % classdef
