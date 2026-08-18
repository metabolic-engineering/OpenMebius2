classdef SteadyStateOptions
    % STEADYSTATEOPTIONS
    % Validated nonlinear optimization options for steady-state MFA.

    properties (SetAccess = private)
        Algorithm (1, 1) string
        MaxFunctionEvaluations (1, 1) double
        MaxIterations (1, 1) double
        FunctionTolerance (1, 1) double
        StepTolerance (1, 1) double
        OptimalityTolerance (1, 1) double
        ConstraintTolerance (1, 1) double
        FiniteDifferenceType (1, 1) string
        FiniteDifferenceStepSize (1, 1) double
        ScaleProblem (1, 1) string
        EnforceFluxBounds (1, 1) logical
        RejectWorseThanInitial (1, 1) logical
        ObjectiveIncreaseTolerance (1, 1) double
        InitialFeasibilityTolerance (1, 1) double
        StepSizeSearchEnabled (1, 1) logical
        IncludeConfiguredStep (1, 1) logical
        MaxStepSizeCandidates (1, 1) double
        StepSizeCandidates (:, 1) double
    end

    methods

        function obj = SteadyStateOptions(options)

            arguments
                options.Algorithm (1, 1) string {mustBeMember( ...
                    options.Algorithm, ...
                    ["sqp", "sqp-legacy", "interior-point"])} = "sqp"
                options.MaxFunctionEvaluations (1, 1) double ...
                    {mustBeInteger, mustBePositive} = 1000000
                options.MaxIterations (1, 1) double ...
                    {mustBeInteger, mustBePositive} = 2000
                options.FunctionTolerance (1, 1) double ...
                    {mustBeNonnegative} = 1e-6
                options.StepTolerance (1, 1) double ...
                    {mustBeNonnegative} = 1e-10
                options.OptimalityTolerance (1, 1) double ...
                    {mustBeNonnegative} = 1e-8
                options.ConstraintTolerance (1, 1) double ...
                    {mustBeNonnegative} = 1e-8
                options.FiniteDifferenceType (1, 1) string ...
                    {mustBeMember(options.FiniteDifferenceType, ...
                    ["forward", "central"])} = "central"
                options.FiniteDifferenceStepSize (1, 1) double ...
                    {mustBePositive} = 1e-6
                options.ScaleProblem (1, 1) string = "obj-and-constr"
                options.EnforceFluxBounds (1, 1) logical = false
                options.RejectWorseThanInitial (1, 1) logical = true
                options.ObjectiveIncreaseTolerance (1, 1) double ...
                    {mustBeNonnegative} = 1e-6
                options.InitialFeasibilityTolerance (1, 1) double ...
                    {mustBeNonnegative} = 1e-7
                options.StepSizeSearchEnabled (1, 1) logical = true
                options.IncludeConfiguredStep (1, 1) logical = true
                options.MaxStepSizeCandidates (1, 1) double ...
                    {mustBeInteger, mustBePositive} = 6
                options.StepSizeCandidates (:, 1) double ...
                    {mustBePositive} = [1e-3; 1e-4; 1e-5; 1e-6; 1e-7]
            end

            obj.Algorithm = options.Algorithm;
            obj.MaxFunctionEvaluations = options.MaxFunctionEvaluations;
            obj.MaxIterations = options.MaxIterations;
            obj.FunctionTolerance = options.FunctionTolerance;
            obj.StepTolerance = options.StepTolerance;
            obj.OptimalityTolerance = options.OptimalityTolerance;
            obj.ConstraintTolerance = options.ConstraintTolerance;
            obj.FiniteDifferenceType = options.FiniteDifferenceType;
            obj.FiniteDifferenceStepSize = ...
                options.FiniteDifferenceStepSize;
            obj.ScaleProblem = options.ScaleProblem;
            obj.EnforceFluxBounds = options.EnforceFluxBounds;
            obj.RejectWorseThanInitial = options.RejectWorseThanInitial;
            obj.ObjectiveIncreaseTolerance = ...
                options.ObjectiveIncreaseTolerance;
            obj.InitialFeasibilityTolerance = ...
                options.InitialFeasibilityTolerance;
            obj.StepSizeSearchEnabled = options.StepSizeSearchEnabled;
            obj.IncludeConfiguredStep = options.IncludeConfiguredStep;
            obj.MaxStepSizeCandidates = options.MaxStepSizeCandidates;
            obj.StepSizeCandidates = options.StepSizeCandidates;

        end % constructor

        function stepSizes = finiteDifferenceStepSizes(obj)

            if ~obj.StepSizeSearchEnabled
                stepSizes = obj.FiniteDifferenceStepSize;
                return
            end

            stepSizes = obj.StepSizeCandidates;

            if obj.IncludeConfiguredStep
                stepSizes = [obj.FiniteDifferenceStepSize; stepSizes];
            end

            stepSizes = stepSizes(isfinite(stepSizes) & stepSizes > 0);

            if isempty(stepSizes)
                stepSizes = obj.FiniteDifferenceStepSize;
            end

            stepSizes = unique(stepSizes, 'stable');
            stepSizes = stepSizes( ...
                1:min(numel(stepSizes), obj.MaxStepSizeCandidates));

        end % finiteDifferenceStepSizes

        function fminconOptions = buildFminconOptions( ...
                obj, initialIndependentValues, finiteDifferenceStepSize)

            arguments
                obj (1, 1) openmebius.mfa.SteadyStateOptions
                initialIndependentValues (:, 1) double
                finiteDifferenceStepSize (1, 1) double {mustBePositive}
            end

            typicalX = max(1, abs(initialIndependentValues));

            try
                fminconOptions = optimoptions('fmincon');
                fminconOptions = obj.setOption( ...
                    fminconOptions, 'Algorithm', char(obj.Algorithm));
                fminconOptions = obj.setOption( ...
                    fminconOptions, 'Display', 'off');
                fminconOptions = obj.setOption( ...
                    fminconOptions, 'MaxFunctionEvaluations', ...
                    obj.MaxFunctionEvaluations);
                fminconOptions = obj.setOption( ...
                    fminconOptions, 'MaxIterations', obj.MaxIterations);
                fminconOptions = obj.setOption( ...
                    fminconOptions, 'FunctionTolerance', ...
                    obj.FunctionTolerance);
                fminconOptions = obj.setOption( ...
                    fminconOptions, 'StepTolerance', obj.StepTolerance);
                fminconOptions = obj.setOption( ...
                    fminconOptions, 'OptimalityTolerance', ...
                    obj.OptimalityTolerance);
                fminconOptions = obj.setOption( ...
                    fminconOptions, 'ConstraintTolerance', ...
                    obj.ConstraintTolerance);
                fminconOptions = obj.setOption( ...
                    fminconOptions, 'FiniteDifferenceType', ...
                    char(obj.FiniteDifferenceType));
                fminconOptions = obj.setOption( ...
                    fminconOptions, 'FiniteDifferenceStepSize', ...
                    finiteDifferenceStepSize);
                fminconOptions = obj.setOption( ...
                    fminconOptions, 'ScaleProblem', ...
                    char(obj.ScaleProblem));
                fminconOptions = obj.setOption( ...
                    fminconOptions, 'TypicalX', typicalX);
                fminconOptions = obj.setOption( ...
                    fminconOptions, 'UseParallel', false);
            catch
                fminconOptions = optimset( ...
                    'Algorithm', char(obj.Algorithm), ...
                    'Display', 'off', ...
                    'MaxFunEvals', obj.MaxFunctionEvaluations, ...
                    'MaxIter', obj.MaxIterations, ...
                    'TolFun', obj.FunctionTolerance, ...
                    'TolX', obj.StepTolerance, ...
                    'TolCon', obj.ConstraintTolerance, ...
                    'FinDiffType', char(obj.FiniteDifferenceType), ...
                    'FinDiffRelStep', finiteDifferenceStepSize, ...
                    'TypicalX', typicalX, ...
                    'UseParallel', false);
            end

        end % buildFminconOptions

    end % methods

    methods (Static, Access = private)

        function options = setOption(options, optionName, optionValue)

            try
                options.(optionName) = optionValue;
            catch
                % Ignore options unavailable in older MATLAB releases.
            end

        end % setOption

    end % methods (Static, Access = private)

end % classdef
