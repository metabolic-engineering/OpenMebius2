classdef RunConfigViewModel
    % RUNCONFIGVIEWMODEL Typed values exchanged with the RunConfig UI.

    properties
        Iteration (1, 1) double = 30
        Algorithm (1, 1) string = "SQP"
        LargeScale (1, 1) logical = false
        FluxLowerBound (1, 1) double = -1000
        FluxUpperBound (1, 1) double = 1000
        FminconMaxFunctionEvaluations (1, 1) double = 1000000
        FminconMaxIterations (1, 1) double = 2000
        FminconFunctionTolerance (1, 1) double = 1e-6
        FminconStepTolerance (1, 1) double = 1e-10
        FminconOptimalityTolerance (1, 1) double = 1e-8
        FminconConstraintTolerance (1, 1) double = 1e-8
        FminconFiniteDifferenceType (1, 1) string = "Central"
        FminconFiniteDifferenceStepSize (1, 1) double = 1e-6
        SearchOptimalFiniteDifferenceStepSize (1, 1) logical = true
        FreeEffluxSeedSigmaMultiplier (1, 1) double = 3
        SuggestNextFlux (1, 1) logical = false
        PerturbateEfflux (1, 1) logical = false
        CalculateCI (1, 1) logical = false
        CIAlgorithm (1, 1) string = "Monte Carlo"
        DeleteResultFile (1, 1) logical = true

        MCIterations (1, 1) double = 500
        MCFixMID (1, 1) logical = true
        MCMIDStandardDeviation (1, 1) double = 0.01
        MCOptimizationProcedure (1, 1) string = "Multiple run"
        MCTerminationTolerance (1, 1) double = 1e-4
        MCProximityThreshold (1, 1) double = 1e-4
        MCCertainThreshold (1, 1) double = 3
        MCNumberOfRuns (1, 1) double = 50
        MCCalculationMethod (1, 1) string = "Discarding"

        GridAutomaticInterval (1, 1) logical = true
        GridParallelExecution (1, 1) logical = true
        GridPoints (1, 1) double = 10
        GridDelta (1, 1) double = 1
        GridIterations (1, 1) double = 30
        GridWorkers (1, 1) double = 8
        GridMinimumFluxRange (1, 1) double = 1e-6
        GridThreshold (1, 1) string = "Chi-squared"
        GridReactionTable table = table()

        IsINSTMFA (1, 1) logical = false
        EffluxTable table = table()
        INSTMFAPoolTable table = table()
        INSTMFATimePointTable table = table()
    end

end % classdef
