classdef SteadyStateSolver
    % STEADYSTATESOLVER
    % Runs guarded steady-state FMINCON finite-difference trials.

    methods

        function result = solve( ...
                ~, problem, rightHandSide, objectiveFunction, ...
                solverOptions, options)

            arguments
                ~
                problem (1, 1) openmebius.mfa.MFAProblem
                rightHandSide (:, 1) double
                objectiveFunction (1, 1) function_handle
                solverOptions (1, 1) openmebius.mfa.SteadyStateOptions
                options.InitialIndependentValues double = []
                options.LinearEqualityMatrix double = zeros(0, 0)
                options.LinearEqualityRightHandSide (:, 1) double = zeros(0, 1)
                options.MessageReporter (1, 1) function_handle = ...
                    @(~, ~) []
            end

            if isempty(options.InitialIndependentValues)
                initialIndependentValues = ...
                    problem.extractIndependentValues(rightHandSide);
            else
                initialIndependentValues = ...
                    options.InitialIndependentValues(:);
            end

            initialObjective = ...
                openmebius.mfa.SteadyStateSolver.evaluateObjective( ...
                objectiveFunction, initialIndependentValues);
            initialViolation = ...
                openmebius.mfa.SteadyStateSolver.constraintViolation( ...
                problem, rightHandSide, initialIndependentValues);
            stepSizes = solverOptions.finiteDifferenceStepSizes();
            trialCount = numel(stepSizes);
            trialObjectives = inf(trialCount, 1);
            trialExitFlags = nan(trialCount, 1);
            trialViolations = inf(trialCount, 1);
            trialGuardTriggered = false(trialCount, 1);
            trialExecutionFailed = false(trialCount, 1);
            trialMessages = strings(trialCount, 1);
            trialOutputs = cell(trialCount, 1);
            trialValues = cell(trialCount, 1);
            suppressGuardMessage = trialCount > 1;
            feasibilityTolerance = max([ ...
                                            solverOptions.ConstraintTolerance, ...
                                            solverOptions.InitialFeasibilityTolerance, ...
                                            eps]);
            bestIndex = 1;
            bestScore = inf;
            bestValues = initialIndependentValues;
            bestObjective = initialObjective;
            bestExitFlag = -101;
            bestOutput = struct;

            for iTrial = 1:trialCount
                stepSize = stepSizes(iTrial);
                fminconOptions = solverOptions.buildFminconOptions( ...
                    initialIndependentValues, stepSize);
                trialResult = ...
                    openmebius.mfa.SteadyStateSolver.runTrial( ...
                    problem, ...
                    rightHandSide, ...
                    objectiveFunction, ...
                    initialIndependentValues, ...
                    fminconOptions, ...
                    stepSize, ...
                    options.LinearEqualityMatrix, ...
                    options.LinearEqualityRightHandSide ...
                );
                trialIndependentValues = trialResult.IndependentValues;
                trialObjective = trialResult.ObjectiveValue;
                trialExitFlag = trialResult.ExitFlag;
                trialOutput = trialResult.Output;
                trialOutput.fminconFiniteDifferenceStepSize = stepSize;
                trialOutput.fminconInitialObjective = initialObjective;
                trialOutput.fminconInitialConstraintViolation = ...
                    initialViolation;
                trialOutput.fminconFinalObjectiveBeforeGuard = ...
                    trialObjective;
                trialOutput.fminconObjectiveGuardTriggered = false;
                [trialIndependentValues, trialObjective, ...
                     trialExitFlag, trialOutput] = ...
                    openmebius.mfa.SteadyStateSolver.applyObjectiveGuard( ...
                    trialIndependentValues, ...
                    trialObjective, ...
                    trialExitFlag, ...
                    trialOutput, ...
                    initialIndependentValues, ...
                    initialObjective, ...
                    initialViolation, ...
                    solverOptions, ...
                    suppressGuardMessage, ...
                    options.MessageReporter);
                trialViolation = ...
                    openmebius.mfa.SteadyStateSolver.constraintViolation( ...
                    problem, rightHandSide, trialIndependentValues);
                trialObjectives(iTrial) = trialObjective;
                trialExitFlags(iTrial) = trialExitFlag;
                trialViolations(iTrial) = trialViolation;
                trialGuardTriggered(iTrial) = ...
                    trialOutput.fminconObjectiveGuardTriggered;
                trialExecutionFailed(iTrial) = ...
                    isfield(trialOutput, 'fminconExecutionFailed') && ...
                    logical(trialOutput.fminconExecutionFailed);

                if isfield(trialOutput, 'message') && ...
                        ~isempty(trialOutput.message)
                    trialMessages(iTrial) = string(trialOutput.message);
                end

                trialOutputs{iTrial} = trialOutput;
                trialValues{iTrial} = trialIndependentValues;

                if isfinite(trialObjective) && ...
                        trialViolation <= 10 * feasibilityTolerance
                    score = trialObjective;
                else
                    score = inf;
                end

                if score < bestScore
                    bestIndex = iTrial;
                    bestScore = score;
                    bestValues = trialIndependentValues;
                    bestObjective = trialObjective;
                    bestExitFlag = trialExitFlag;
                    bestOutput = trialOutput;
                end

            end

            if ~isfinite(bestScore)

                if isfinite(initialObjective) && ...
                        initialViolation <= 10 * feasibilityTolerance
                    bestIndex = 1;
                    bestValues = initialIndependentValues;
                    bestObjective = initialObjective;
                    bestExitFlag = -103;
                    bestOutput = struct;
                    bestOutput.message = ...
                        "No FMINCON finite-difference step-size trial " + ...
                        "improved a feasible initial point.";
                    bestOutput.fminconExecutionFailed = false;
                else
                    finiteMask = isfinite(trialObjectives);

                    if any(finiteMask)
                        finiteObjectives = trialObjectives;
                        finiteObjectives(~finiteMask) = inf;
                        [~, bestIndex] = min(finiteObjectives);
                        bestValues = trialValues{bestIndex};
                        bestObjective = trialObjectives(bestIndex);
                        bestExitFlag = trialExitFlags(bestIndex);
                        bestOutput = trialOutputs{bestIndex};
                    else
                        bestIndex = 1;
                        bestValues = initialIndependentValues;
                        bestObjective = initialObjective;
                        bestExitFlag = -102;
                        bestOutput = struct;
                        bestOutput.message = ...
                            "All FMINCON finite-difference " + ...
                            "step-size trials failed.";
                        bestOutput.fminconExecutionFailed = true;
                    end

                end

            end

            searchOutput = struct;
            searchOutput.enabled = solverOptions.StepSizeSearchEnabled;
            searchOutput.candidates = stepSizes(:);
            searchOutput.objectives = trialObjectives;
            searchOutput.exitflags = trialExitFlags;
            searchOutput.constraintViolations = trialViolations;
            searchOutput.objectiveGuardTriggered = trialGuardTriggered;
            searchOutput.executionFailed = trialExecutionFailed;
            searchOutput.messages = trialMessages;
            searchOutput.bestIndex = bestIndex;
            searchOutput.bestFiniteDifferenceStepSize = ...
                stepSizes(bestIndex);
            searchOutput.bestObjective = bestObjective;
            output = bestOutput;

            if ~isfield(output, 'fminconInitialObjective')
                output.fminconInitialObjective = initialObjective;
            end

            if ~isfield(output, 'fminconInitialConstraintViolation')
                output.fminconInitialConstraintViolation = initialViolation;
            end

            if ~isfield(output, 'fminconFinalObjectiveBeforeGuard')
                output.fminconFinalObjectiveBeforeGuard = bestObjective;
            end

            if ~isfield(output, 'fminconObjectiveGuardTriggered')
                output.fminconObjectiveGuardTriggered = false;
            end

            output.fminconFiniteDifferenceStepSize = stepSizes(bestIndex);
            output.fminconFiniteDifferenceStepSizeSearch = searchOutput;

            if isfield(output, 'fminconExecutionFailed') && ...
                    logical(output.fminconExecutionFailed)
                errorMessage = string(output.message);
            else
                errorMessage = "";
            end

            flux = problem.solveFlux( ...
                bestValues, ...
                BaseRightHandSide = rightHandSide);
            result = openmebius.mfa.SteadyStateResult( ...
                IndependentValues = bestValues, ...
                Flux = flux, ...
                ObjectiveValue = bestObjective, ...
                ExitFlag = bestExitFlag, ...
                Output = output, ...
                ErrorMessage = errorMessage);

        end % solve

    end % methods

    methods (Static, Access = private)

        function result = runTrial( ...
                problem, rightHandSide, objectiveFunction, ...
                initialIndependentValues, fminconOptions, stepSize, ...
                equalityMatrix, equalityRightHandSide)

            try
                [inequalityMatrix, inequalityRightHandSide] = ...
                    problem.nonnegativeFluxInequalities( ...
                    BaseRightHandSide = rightHandSide);
                [independentValues, objectiveValue, exitFlag, output] = ...
                    fmincon( ...
                    objectiveFunction, ...
                    initialIndependentValues, ...
                    inequalityMatrix, ...
                    inequalityRightHandSide, ...
                    equalityMatrix, ...
                    equalityRightHandSide, ...
                    [], ...
                    [], ...
                    [], ...
                    fminconOptions ...
                );

                if ~isscalar(objectiveValue) || ~isfinite(objectiveValue)
                    objectiveValue = inf;
                end

                output.fminconExecutionFailed = false;
                errorMessage = "";
            catch ME
                independentValues = initialIndependentValues;
                objectiveValue = inf;
                exitFlag = -200;
                output = struct;
                output.message = ...
                    "FMINCON failed at FiniteDifferenceStepSize=" + ...
                    string(stepSize) + ": " + string(ME.message);
                output.fminconExecutionFailed = true;
                output.fminconExceptionIdentifier = string(ME.identifier);
                errorMessage = string(ME.message);
            end

            flux = problem.solveFlux( ...
                independentValues, ...
                BaseRightHandSide = rightHandSide);
            result = openmebius.mfa.SteadyStateResult( ...
                IndependentValues = independentValues, ...
                Flux = flux, ...
                ObjectiveValue = objectiveValue, ...
                ExitFlag = exitFlag, ...
                Output = output, ...
                ErrorMessage = errorMessage);

        end % runTrial

        function value = evaluateObjective(objectiveFunction, values)

            try
                value = objectiveFunction(values);

                if ~isscalar(value) || ~isfinite(value)
                    value = inf;
                end

            catch
                value = inf;
            end

        end % evaluateObjective

        function violation = constraintViolation( ...
                problem, rightHandSide, independentValues)

            try
                flux = problem.solveFlux( ...
                    independentValues, ...
                    BaseRightHandSide = rightHandSide);
                violation = max([0; -flux(:)]);

                if ~isfinite(violation)
                    violation = inf;
                end

            catch
                violation = inf;
            end

        end % constraintViolation

        function [values, objective, exitFlag, output] = ...
                applyObjectiveGuard( ...
                values, objective, exitFlag, output, ...
                initialValues, initialObjective, initialViolation, ...
                solverOptions, suppressMessage, messageReporter)

            if ~solverOptions.RejectWorseThanInitial || ...
                    ~isfinite(initialObjective) || ...
                    initialViolation > ...
                    solverOptions.InitialFeasibilityTolerance
                return
            end

            allowedObjective = initialObjective + ...
                solverOptions.ObjectiveIncreaseTolerance * ...
                max(1, abs(initialObjective));

            if isfinite(objective) && objective <= allowedObjective
                return
            end

            output.fminconObjectiveGuardTriggered = true;
            output.fminconRejectedObjective = objective;
            output.fminconRejectedExitflag = exitFlag;
            output.fminconRejectedMessage = ...
                "FMINCON returned a worse objective than the " + ...
                "feasible initial point.";

            if ~suppressMessage
                messageReporter( ...
                    "warning", ...
                    "FMINCON returned a worse objective (" + ...
                    string(objective) + ") than the feasible " + ...
                    "initial objective (" + string(initialObjective) + ...
                "). Reverting to the initial point for this trial.");
            end

            values = initialValues;
            objective = initialObjective;
            exitFlag = -100;

        end % applyObjectiveGuard

    end % methods (Static, Access = private)

end % classdef
