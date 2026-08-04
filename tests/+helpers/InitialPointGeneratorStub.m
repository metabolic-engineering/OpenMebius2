classdef InitialPointGeneratorStub < handle

    properties (SetAccess = private)
        Fluxes (:, :) double
        RightHandSides (:, :) double
        IsCanceled (1, 1) logical = false
        IsError (1, 1) logical = false
        ErrorMessage (1, 1) string = ""
        LastProblem = []
    end

    methods

        function obj = InitialPointGeneratorStub( ...
                fluxes, rightHandSides, options)

            arguments
                fluxes double
                rightHandSides double
                options.IsCanceled (1, 1) logical = false
                options.IsError (1, 1) logical = false
                options.ErrorMessage (1, 1) string = ""
            end

            obj.Fluxes = fluxes;
            obj.RightHandSides = rightHandSides;
            obj.IsCanceled = options.IsCanceled;
            obj.IsError = options.IsError;
            obj.ErrorMessage = options.ErrorMessage;

        end

        function result = generateRandom(obj, problem, ~, varargin)

            obj.LastProblem = problem;
            result = obj.result();

        end

        function result = generateHitAndRun( ...
                obj, problem, ~, ~, varargin)

            obj.LastProblem = problem;
            result = obj.result();

        end

    end

    methods (Access = private)

        function value = result(obj)

            value = openmebius.mfa.InitialPointResult( ...
                Fluxes = obj.Fluxes, ...
                RightHandSides = obj.RightHandSides, ...
                IsCanceled = obj.IsCanceled, ...
                IsError = obj.IsError, ...
                ErrorMessage = obj.ErrorMessage);

        end

    end

end
