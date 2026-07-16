classdef InstationaryInputSpecification
    % INSTATIONARYINPUTSPECIFICATION
    % Typed, unaligned pool-size and time-point settings for INST-MFA.

    properties (SetAccess = private)
        PoolMetabolites (:, 1) string
        PoolSizes (:, 1) double
        TimePoints (:, 1) double
    end

    methods

        function obj = InstationaryInputSpecification(options)

            arguments
                options.PoolMetabolites (:, 1) string = strings(0, 1)
                options.PoolSizes (:, 1) double
                options.TimePoints (:, 1) double
            end

            obj.PoolMetabolites = options.PoolMetabolites;
            obj.PoolSizes = options.PoolSizes;
            obj.TimePoints = options.TimePoints;

        end

    end

end
