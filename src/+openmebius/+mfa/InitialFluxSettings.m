classdef InitialFluxSettings
    % INITIALFLUXSETTINGS
    % Validated settings for initial flux candidate generation.

    properties (SetAccess = private)
        IterationCount (1, 1) double
        RestrictFreeEffluxSeeds (1, 1) logical
        FreeEffluxSeedSigmaMultiplier (1, 1) double
    end

    methods

        function obj = InitialFluxSettings(options)

            arguments
                options.IterationCount (1, 1) double = 30
                options.RestrictFreeEffluxSeeds (1, 1) logical = true
                options.FreeEffluxSeedSigmaMultiplier ...
                    (1, 1) double = 3
            end

            if ~isfinite(options.IterationCount) || ...
                    options.IterationCount <= 0 || ...
                    fix(options.IterationCount) ~= options.IterationCount
                error( ...
                    "OpenMebius2:InitialFluxSettings:" + ...
                    "InvalidIterationCount", ...
                    "The initial-flux iteration count must be a " + ...
                "positive integer.");
            end

            if ~isfinite(options.FreeEffluxSeedSigmaMultiplier) || ...
                    options.FreeEffluxSeedSigmaMultiplier <= 0
                error( ...
                    "OpenMebius2:InitialFluxSettings:" + ...
                    "InvalidFreeEffluxSeedSigmaMultiplier", ...
                    "The free-efflux seed sigma multiplier must be " + ...
                "positive and finite.");
            end

            obj.IterationCount = options.IterationCount;
            obj.RestrictFreeEffluxSeeds = ...
                options.RestrictFreeEffluxSeeds;
            obj.FreeEffluxSeedSigmaMultiplier = ...
                options.FreeEffluxSeedSigmaMultiplier;

        end

    end

end
