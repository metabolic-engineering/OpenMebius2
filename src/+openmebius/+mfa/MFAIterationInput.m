classdef MFAIterationInput
    % MFAITERATIONINPUT Validated input for one nonlinear MFA fit.

    properties (SetAccess = private)
        Settings
        Problem
        Model
        ExperimentalData
        ExperimentalMDV double
        RightHandSide (:, 1) double
        SubstrateEMUs cell
        InstationaryInput = []
        SubstrateList (:, 1) string
        Efflux (:, 1) double
        EffluxStandardDeviation (:, 1) double
        EffluxFree (:, 1) logical
        GrowthRate (1, 1) double
        GrowthRateStandardDeviation (1, 1) double
        GrowthRateFree (1, 1) logical
    end

    methods

        function obj = MFAIterationInput(options)

            arguments
                options.Settings (1, 1) ...
                    openmebius.mfa.MFAIterationSettings
                options.Problem (1, 1) openmebius.mfa.MFAProblem
                options.Model
                options.ExperimentalData (1, 1) ...
                    openmebius.mfa.MFAExperimentalData
                options.ExperimentalMDV double
                options.RightHandSide (:, 1) double
                options.SubstrateEMUs cell
                options.InstationaryInput = []
                options.SubstrateList
                options.Efflux double
                options.EffluxStandardDeviation double
                options.EffluxFree
                options.GrowthRate (1, 1) double = NaN
                options.GrowthRateStandardDeviation (1, 1) double = NaN
                options.GrowthRateFree (1, 1) logical = false
            end

            options.Problem.extractIndependentValues( ...
                options.RightHandSide);
            substrateList = string(options.SubstrateList(:));
            efflux = options.Efflux(:);
            effluxStandardDeviation = ...
                options.EffluxStandardDeviation(:);
            effluxFree = logical(options.EffluxFree(:));

            if ~isempty(effluxFree) && ...
                    (numel(effluxFree) ~= numel(substrateList) || ...
                    numel(efflux) ~= numel(substrateList) || ...
                    numel(effluxStandardDeviation) ~= ...
                    numel(substrateList))
                error( ...
                    "OpenMebius2:MFAIterationInput:EffluxDimensionMismatch", ...
                "Efflux values must match the substrate list.");
            end

            useInstationary = ...
                options.Settings.AnalysisMode.isInstationary();

            if useInstationary && isempty(options.InstationaryInput)
                error( ...
                    "OpenMebius2:MFAIterationInput:" + ...
                    "MissingInstationaryInput", ...
                    "Instationary MFA requires validated pool sizes " + ...
                "and time points.");
            end

            if useInstationary && isempty(options.SubstrateEMUs)
                error( ...
                    "OpenMebius2:MFAIterationInput:MissingSubstrateEMU", ...
                "Instationary MFA requires a substrate EMU.");
            end

            if ~useInstationary
                options.ExperimentalData.arrangeMDV( ...
                    options.ExperimentalMDV, ...
                    ExperimentCount = numel(options.SubstrateEMUs));
            end

            obj.Settings = options.Settings;
            obj.Problem = options.Problem;
            obj.Model = options.Model;
            obj.ExperimentalData = options.ExperimentalData;
            obj.ExperimentalMDV = options.ExperimentalMDV;
            obj.RightHandSide = options.RightHandSide;
            obj.SubstrateEMUs = options.SubstrateEMUs;
            obj.InstationaryInput = options.InstationaryInput;
            obj.SubstrateList = substrateList;
            obj.Efflux = efflux;
            obj.EffluxStandardDeviation = effluxStandardDeviation;
            obj.EffluxFree = effluxFree;
            obj.GrowthRate = options.GrowthRate;
            obj.GrowthRateStandardDeviation = ...
                options.GrowthRateStandardDeviation;
            obj.GrowthRateFree = options.GrowthRateFree;

        end % constructor

        function mode = analysisMode(obj)

            mode = obj.Settings.AnalysisMode;

        end % analysisMode

        function arrangedMDV = arrangedExperimentalMDV(obj)

            arrangedMDV = obj.ExperimentalData.arrangeMDV( ...
                obj.ExperimentalMDV, ...
                ExperimentCount = numel(obj.SubstrateEMUs));

        end % arrangedExperimentalMDV

    end % methods

end % classdef
