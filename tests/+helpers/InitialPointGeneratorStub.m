classdef InitialPointGeneratorStub < handle

    properties (SetAccess = private)
        Fluxes (:, :) double
        RightHandSides (:, :) double
        IsCanceled (1, 1) logical = false
        IsError (1, 1) logical = false
        ErrorMessage (1, 1) string = ""
        LastProblem = []
        RetryFluxes (:, :) double = zeros(0, 0)
        RetryRightHandSides (:, :) double = zeros(0, 0)
        GenerationCount (1, 1) double = 0
        DelaySeconds (1, 1) double = 0
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
                options.RetryFluxes double = zeros(0, 0)
                options.RetryRightHandSides double = zeros(0, 0)
                options.DelaySeconds (1, 1) double = 0
            end

            obj.Fluxes = fluxes;
            obj.RightHandSides = rightHandSides;
            obj.IsCanceled = options.IsCanceled;
            obj.IsError = options.IsError;
            obj.ErrorMessage = options.ErrorMessage;
            obj.RetryFluxes = options.RetryFluxes;
            obj.RetryRightHandSides = options.RetryRightHandSides;
            obj.DelaySeconds = options.DelaySeconds;

        end

        function result = generateRandom(obj, problem, ~, varargin)

            obj.LastProblem = problem;
            obj.GenerationCount = obj.GenerationCount + 1;
            pause(obj.DelaySeconds);
            result = obj.result();

        end

        function result = generateHitAndRun( ...
                obj, problem, ~, ~, varargin)

            obj.LastProblem = problem;
            obj.GenerationCount = obj.GenerationCount + 1;
            pause(obj.DelaySeconds);
            result = obj.result();

        end

    end

    methods (Access = private)

        function value = result(obj)

            fluxes = obj.Fluxes;
            rightHandSides = obj.RightHandSides;

            if obj.GenerationCount > 1 && ~isempty(obj.RetryFluxes)
                fluxes = obj.RetryFluxes;
                rightHandSides = obj.RetryRightHandSides;
            end

            value = openmebius.mfa.InitialPointResult( ...
                Fluxes = fluxes, ...
                RightHandSides = rightHandSides, ...
                IsCanceled = obj.IsCanceled, ...
                IsError = obj.IsError, ...
                ErrorMessage = obj.ErrorMessage);

        end

    end

end
