classdef GridSearchConfidenceIntervalSolverStub < handle

    properties (SetAccess = private)
        CallCount (1, 1) double = 0
        LastBaseRightHandSide double = []
        LastEvaluationResult = []
        LastEqualityMatrix double = zeros(0, 0)
        LastEqualityRightHandSide double = zeros(0, 1)
        LastInitialIndependentValues double = []
        LastProfileFluxIndices double = zeros(0, 1)
        LastObjectiveThreshold double = NaN
        LastBestObjective double = NaN
    end

    methods

        function result = solve( ...
                obj, problem, bestFlux, baseRightHandSide, ~, ...
                evaluationFunction, ~, options)

            arguments
                obj
                problem
                bestFlux
                baseRightHandSide
                ~
                evaluationFunction
                ~
                options.ProfileFluxIndices double = zeros(0, 1)
                options.ObjectiveThreshold double = NaN
                options.BestObjective double = NaN
                options.InitialIndependentValues double = []
                options.MessageReporter function_handle = @(~, ~) []
                options.CancellationRequested function_handle = @() false
            end

            obj.CallCount = obj.CallCount + 1;
            obj.LastBaseRightHandSide = baseRightHandSide;
            obj.LastProfileFluxIndices = ...
                options.ProfileFluxIndices;
            obj.LastObjectiveThreshold = ...
                options.ObjectiveThreshold;
            obj.LastBestObjective = options.BestObjective;

            if isempty(options.InitialIndependentValues)
                obj.LastInitialIndependentValues = ...
                    problem.extractIndependentValues(baseRightHandSide);
            else
                obj.LastInitialIndependentValues = ...
                    options.InitialIndependentValues(:, 1);
            end

            obj.LastEqualityMatrix = ...
                ones(1, numel(obj.LastInitialIndependentValues));
            obj.LastEqualityRightHandSide = ...
                obj.LastEqualityMatrix * ...
                obj.LastInitialIndependentValues;
            obj.LastEvaluationResult = evaluationFunction( ...
                obj.LastEqualityMatrix, ...
                obj.LastEqualityRightHandSide, ...
                obj.LastInitialIndependentValues);

            fluxCount = size(bestFlux, 1);
            profile = openmebius.mfa.GridSearchProfileData( ...
                FluxIndices = (1:fluxCount).', ...
                FixedFluxValues = zeros(fluxCount, 1, 1), ...
                MinimumSumOfSquares = zeros(fluxCount, 1, 1));
            result = openmebius.mfa ...
                .GridSearchConfidenceIntervalResult( ...
                LowerBounds = zeros(fluxCount, 1), ...
                UpperBounds = ones(fluxCount, 1), ...
                ProfileData = profile, ...
                ElapsedTime = 3);

        end

    end

end
