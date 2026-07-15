classdef InitialPointGeneratorStub

    properties (SetAccess = private)
        Fluxes (:, :) double
        RightHandSides (:, :) double
    end

    methods

        function obj = InitialPointGeneratorStub(fluxes, rightHandSides)

            obj.Fluxes = fluxes;
            obj.RightHandSides = rightHandSides;

        end

        function result = generateRandom(obj, ~, ~, varargin)

            result = obj.result();

        end

        function result = generateHitAndRun( ...
                obj, ~, ~, ~, varargin)

            result = obj.result();

        end

    end

    methods (Access = private)

        function value = result(obj)

            value = openmebius.mfa.InitialPointResult( ...
                Fluxes = obj.Fluxes, ...
                RightHandSides = obj.RightHandSides);

        end

    end

end
