classdef InitialFluxSettings
    % INITIALFLUXSETTINGS
    % Validated settings for initial flux candidate generation.

    properties (SetAccess = private)
        IterationCount (1, 1) double
    end

    methods

        function obj = InitialFluxSettings(options)

            arguments
                options.IterationCount (1, 1) double = 30
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

            obj.IterationCount = options.IterationCount;

        end

    end

end
