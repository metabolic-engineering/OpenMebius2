classdef InstationaryInput
    % INSTATIONARYINPUT
    % Immutable, validated pool sizes and time points for INST-MFA.

    properties (SetAccess = private)
        PoolSizes (:, 1) double
        TimePoints (:, 1) double
    end

    methods

        function obj = InstationaryInput(options)

            arguments
                options.PoolSizes (:, 1) double
                options.TimePoints (:, 1) double
            end

            if isempty(options.PoolSizes) || ...
                    any(~isfinite(options.PoolSizes)) || ...
                    any(options.PoolSizes <= 0)
                error( ...
                    "OpenMebius2:InstationaryInput:InvalidPoolSize", ...
                    "Pool sizes must be positive and finite.");
            end

            if numel(options.TimePoints) < 2 || ...
                    any(~isfinite(options.TimePoints)) || ...
                    any(options.TimePoints < 0)
                error( ...
                    "OpenMebius2:InstationaryInput:InvalidTimePoints", ...
                    "At least two finite nonnegative time points are required.");
            end

            obj.PoolSizes = options.PoolSizes;
            obj.TimePoints = options.TimePoints;

        end % constructor

    end % methods

end % classdef
