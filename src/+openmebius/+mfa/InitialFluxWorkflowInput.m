classdef InitialFluxWorkflowInput
    % INITIALFLUXWORKFLOWINPUT Validated inputs for initial-flux search.

    properties (SetAccess = private)
        Model
        IterationCount (1, 1) double
        RightHandSide (:, 1) double
        LowerBounds (:, 1) double
        UpperBounds (:, 1) double
        SubstrateEMUs cell
        ExperimentalData
        EffluxPenalty
    end

    methods

        function obj = InitialFluxWorkflowInput(options)

            arguments
                options.Model
                options.IterationCount (1, 1) double
                options.RightHandSide (:, 1) double
                options.LowerBounds (:, 1) double
                options.UpperBounds (:, 1) double
                options.SubstrateEMUs cell
                options.ExperimentalData (1, 1) ...
                    openmebius.mfa.MFAExperimentalData
                options.EffluxPenalty
            end

            if ~isfinite(options.IterationCount) || ...
                    options.IterationCount <= 0 || ...
                    fix(options.IterationCount) ~= options.IterationCount
                error( ...
                    "OpenMebius2:InitialFluxInput:InvalidIterationCount", ...
                    "The initial-flux iteration count must be a " + ...
                    "positive integer.");
            end

            if ~ismethod(options.Model, 'getS') || ...
                    ~ismethod(options.Model, 'getSType')
                error( ...
                    "OpenMebius2:InitialFluxInput:InvalidModel", ...
                    "The model must expose getS() and getSType().");
            end

            stoichiometry = options.Model.getS();

            if ~istable(stoichiometry)
                error( ...
                    "OpenMebius2:InitialFluxInput:InvalidStoichiometry", ...
                    "The model stoichiometry must be a table.");
            end

            if numel(options.RightHandSide) ~= height(stoichiometry) || ...
                    numel(options.LowerBounds) ~= width(stoichiometry) || ...
                    numel(options.UpperBounds) ~= width(stoichiometry)
                error( ...
                    "OpenMebius2:InitialFluxInput:DimensionMismatch", ...
                    "Initial-flux vectors must match the stoichiometry dimensions.");
            end

            if any(options.LowerBounds > options.UpperBounds)
                error( ...
                    "OpenMebius2:InitialFluxInput:InvalidBounds", ...
                    "Flux lower bounds must not exceed upper bounds.");
            end

            if ~ismethod(options.EffluxPenalty, 'evaluate')
                error( ...
                    "OpenMebius2:InitialFluxInput:InvalidEffluxPenalty", ...
                    "The efflux penalty must implement evaluate().");
            end

            obj.Model = options.Model;
            obj.IterationCount = options.IterationCount;
            obj.RightHandSide = options.RightHandSide;
            obj.LowerBounds = options.LowerBounds;
            obj.UpperBounds = options.UpperBounds;
            obj.SubstrateEMUs = options.SubstrateEMUs;
            obj.ExperimentalData = options.ExperimentalData;
            obj.EffluxPenalty = options.EffluxPenalty;

        end % constructor

        function substrateEMUs = scoringSubstrateEMUs( ...
                obj, forNextSuggestion)

            arguments
                obj (1, 1) openmebius.mfa.InitialFluxWorkflowInput
                forNextSuggestion (1, 1) logical
            end

            substrateEMUs = obj.SubstrateEMUs;

            if forNextSuggestion
                substrateEMUs = substrateEMUs(1:end - 1);
            end

        end % scoringSubstrateEMUs

        function arrangedMDV = arrangeMDV(obj, experimentCount)

            arguments
                obj (1, 1) openmebius.mfa.InitialFluxWorkflowInput
                experimentCount (1, 1) double
            end

            arrangedMDV = obj.ExperimentalData.arrangeMDV( ...
                obj.ExperimentalData.ExperimentalMDV, ...
                ExperimentCount = experimentCount);

        end % arrangeMDV

    end % methods

end % classdef
