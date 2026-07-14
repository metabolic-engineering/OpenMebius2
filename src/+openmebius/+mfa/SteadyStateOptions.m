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

    methods (Static)

        function [options, warnings] = fromBatchConfig(config)

            if nargin < 1 || isempty(config) || ~isstruct(config)
                config = struct;
            end

            warnings = strings(0, 1);
            algorithm = "sqp";

            if isfield(config, 'algorithm') && ~isempty(config.algorithm)
                candidate = lower(string(config.algorithm));
                candidate = candidate(1);

                switch candidate
                    case {"sqp", "sqp-legacy"}
                        algorithm = candidate;
                    case {"ipms", "interior-point", "interior point"}
                        algorithm = "interior-point";
                    otherwise
                        warnings(end + 1, 1) = ...
                            "Unknown FMINCON algorithm '" + candidate + ...
                            "'. Using sqp.";
                end
            end

            userConfig = struct;

            if isfield(config, 'fmincon') && isstruct(config.fmincon)
                userConfig = config.fmincon;
            end

            finiteDifferenceType = lower(string( ...
                openmebius.mfa.SteadyStateOptions.readString( ...
                userConfig, 'finiteDifferenceType', 'central')));

            if ~ismember(finiteDifferenceType, ["forward", "central"])
                finiteDifferenceType = "central";
            end

            searchConfig = ...
                openmebius.mfa.SteadyStateOptions.readSearchConfig( ...
                userConfig);
            defaultCandidates = [1e-3; 1e-4; 1e-5; 1e-6; 1e-7];
            options = openmebius.mfa.SteadyStateOptions( ...
                Algorithm = algorithm, ...
                MaxFunctionEvaluations = max(1000, round( ...
                openmebius.mfa.SteadyStateOptions.readNumeric( ...
                userConfig, 'maxFunctionEvaluations', 1000000))), ...
                MaxIterations = max(100, round( ...
                openmebius.mfa.SteadyStateOptions.readNumeric( ...
                userConfig, 'maxIterations', 2000))), ...
                FunctionTolerance = max(0, ...
                openmebius.mfa.SteadyStateOptions.readNumeric( ...
                userConfig, 'functionTolerance', 1e-6)), ...
                StepTolerance = max(0, ...
                openmebius.mfa.SteadyStateOptions.readNumeric( ...
                userConfig, 'stepTolerance', 1e-10)), ...
                OptimalityTolerance = max(0, ...
                openmebius.mfa.SteadyStateOptions.readNumeric( ...
                userConfig, 'optimalityTolerance', 1e-8)), ...
                ConstraintTolerance = max(0, ...
                openmebius.mfa.SteadyStateOptions.readNumeric( ...
                userConfig, 'constraintTolerance', 1e-8)), ...
                FiniteDifferenceType = finiteDifferenceType, ...
                FiniteDifferenceStepSize = max(eps, ...
                openmebius.mfa.SteadyStateOptions.readNumeric( ...
                userConfig, 'finiteDifferenceStepSize', 1e-6)), ...
                ScaleProblem = string( ...
                openmebius.mfa.SteadyStateOptions.readString( ...
                userConfig, 'scaleProblem', 'obj-and-constr')), ...
                RejectWorseThanInitial = ...
                openmebius.mfa.SteadyStateOptions.readLogical( ...
                userConfig, 'rejectWorseThanInitial', true), ...
                ObjectiveIncreaseTolerance = max(0, ...
                openmebius.mfa.SteadyStateOptions.readNumeric( ...
                userConfig, 'objectiveIncreaseTolerance', 1e-6)), ...
                InitialFeasibilityTolerance = max(0, ...
                openmebius.mfa.SteadyStateOptions.readNumeric( ...
                userConfig, 'initialFeasibilityTolerance', 1e-7)), ...
                StepSizeSearchEnabled = ...
                openmebius.mfa.SteadyStateOptions.readLogical( ...
                searchConfig, 'enabled', true), ...
                IncludeConfiguredStep = ...
                openmebius.mfa.SteadyStateOptions.readLogical( ...
                searchConfig, 'includeConfiguredStep', true), ...
                MaxStepSizeCandidates = max(1, round( ...
                openmebius.mfa.SteadyStateOptions.readNumeric( ...
                searchConfig, 'maxCandidates', ...
                numel(defaultCandidates) + 1))), ...
                StepSizeCandidates = ...
                openmebius.mfa.SteadyStateOptions.readNumericVector( ...
                searchConfig, 'candidates', defaultCandidates));

        end % fromBatchConfig

    end % methods (Static)

    methods (Static, Access = private)

        function options = setOption(options, optionName, optionValue)

            try
                options.(optionName) = optionValue;
            catch
                % Ignore options unavailable in older MATLAB releases.
            end

        end % setOption

        function searchConfig = readSearchConfig(userConfig)

            searchConfig = struct;

            if isfield(userConfig, 'finiteDifferenceStepSizeSearch') && ...
                    ~isempty(userConfig.finiteDifferenceStepSizeSearch)
                candidate = userConfig.finiteDifferenceStepSizeSearch;
            elseif isfield(userConfig, 'stepSizeSearch') && ...
                    ~isempty(userConfig.stepSizeSearch)
                candidate = userConfig.stepSizeSearch;
            else
                return
            end

            if isstruct(candidate)
                searchConfig = candidate;
            else
                searchConfig.enabled = candidate;
            end

        end % readSearchConfig

        function value = readNumeric(config, fieldName, defaultValue)

            value = defaultValue;

            if isstruct(config) && isfield(config, fieldName) && ...
                    ~isempty(config.(fieldName))
                candidate = config.(fieldName);

                if isnumeric(candidate) || islogical(candidate)
                    value = double(candidate(1));
                end
            end

        end % readNumeric

        function value = readLogical(config, fieldName, defaultValue)

            value = defaultValue;

            if isstruct(config) && isfield(config, fieldName) && ...
                    ~isempty(config.(fieldName))
                candidate = config.(fieldName);

                if islogical(candidate) || isnumeric(candidate)
                    value = logical(candidate(1));
                elseif ischar(candidate) || isstring(candidate)
                    candidate = lower(string(candidate));
                    value = ismember( ...
                        candidate(1), ["true", "1", "yes", "on"]);
                end
            end

        end % readLogical

        function value = readString(config, fieldName, defaultValue)

            value = string(defaultValue);

            if isstruct(config) && isfield(config, fieldName) && ...
                    ~isempty(config.(fieldName))
                candidate = config.(fieldName);

                if ischar(candidate) || isstring(candidate)
                    candidate = string(candidate);
                    value = candidate(1);
                end
            end

        end % readString

        function values = readNumericVector( ...
                config, fieldName, defaultValues)

            values = double(defaultValues(:));

            if isstruct(config) && isfield(config, fieldName) && ...
                    ~isempty(config.(fieldName))
                candidate = config.(fieldName);

                if isnumeric(candidate) || islogical(candidate)
                    values = double(candidate(:));
                elseif iscell(candidate)
                    values = [];

                    for i = 1:numel(candidate)
                        item = candidate{i};

                        if isnumeric(item) || islogical(item)
                            values = [values; double(item(:))]; %#ok<AGROW>
                        elseif ischar(item) || isstring(item)
                            values = [values; ...
                                openmebius.mfa.SteadyStateOptions ...
                                .parseNumericTokens(item)]; %#ok<AGROW>
                        end
                    end
                elseif ischar(candidate) || isstring(candidate)
                    values = openmebius.mfa.SteadyStateOptions ...
                        .parseNumericTokens(candidate);
                end
            end

            values = values(isfinite(values) & values > 0);

            if isempty(values)
                values = double(defaultValues(:));
            end

        end % readNumericVector

        function values = parseNumericTokens(candidate)

            tokenPattern = '[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?';
            tokens = regexp(char(candidate), tokenPattern, 'match');
            values = str2double(tokens(:));
            values = values(isfinite(values));

        end % parseNumericTokens

    end % methods (Static, Access = private)

end % classdef
