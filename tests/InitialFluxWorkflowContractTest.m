classdef InitialFluxWorkflowContractTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(InitialFluxWorkflowContractTest.sourcePath());

        end

    end

    methods (Test)

        function inputReplacesRawConfigurationWithIterationCount(testCase)

            input = InitialFluxWorkflowContractTest.createInput();

            testCase.verifyEqual(input.IterationCount, 2);
            testCase.verifyEqual(input.RightHandSide, [5; 0]);
            testCase.verifyEqual(input.scoringSubstrateEMUs(false), {1});

        end

        function inputRejectsInvalidIterationCount(testCase)

            testCase.verifyError( ...
                @() InitialFluxWorkflowContractTest.createInput( ...
                    IterationCount = 0), ...
                "OpenMebius2:InitialFluxInput:InvalidIterationCount");

        end

        function inputRejectsMismatchedBounds(testCase)

            testCase.verifyError( ...
                @() InitialFluxWorkflowContractTest.createInput( ...
                    UpperBounds = 1), ...
                "OpenMebius2:InitialFluxInput:DimensionMismatch");

        end

        function resultSeparatesCancellationFromFailure(testCase)

            result = openmebius.mfa.InitialFluxWorkflowResult.canceled();

            testCase.verifyTrue(result.IsCanceled);
            testCase.verifyFalse(result.IsError);

        end

        function failedResultRequiresMessage(testCase)

            testCase.verifyError( ...
                @() openmebius.mfa.InitialFluxWorkflowResult( ...
                    IsError = true), ...
                "OpenMebius2:InitialFluxResult:MissingErrorMessage");

        end

        function workflowHandlesRandomGenerationFailure(testCase)

            generator = helpers.InitialPointGeneratorStub( ...
                zeros(2, 0), ...
                zeros(2, 0), ...
                IsError = true, ...
                ErrorMessage = "generation failed");
            workflow = openmebius.mfa.InitialFluxWorkflow( ...
                PointGenerator = generator, ...
                MDVPredictor = helpers.MDVPredictorStub());

            result = workflow.run( ...
                InitialFluxWorkflowContractTest.createInput(), ...
                Method = "random");

            testCase.verifyTrue(result.IsError);
            testCase.verifyFalse(result.IsCanceled);
            testCase.verifyEqual(result.ErrorMessage, "generation failed");

        end

        function workflowRejectsEmptyGeneratedCandidates(testCase)

            generator = helpers.InitialPointGeneratorStub( ...
                zeros(2, 0), zeros(2, 0));
            workflow = openmebius.mfa.InitialFluxWorkflow( ...
                PointGenerator = generator, ...
                MDVPredictor = helpers.MDVPredictorStub());

            result = workflow.run( ...
                InitialFluxWorkflowContractTest.createInput(), ...
                Method = "random");

            testCase.verifyTrue(result.IsError);
            testCase.verifyEqual( ...
                result.ErrorMessage, ...
                "Initial point generation produced no candidates.");

        end

        function workflowReturnsCanceledResultWithoutError(testCase)

            generator = helpers.InitialPointGeneratorStub( ...
                [5; 0.5], ...
                [5; 0.5], ...
                IsCanceled = true);
            workflow = openmebius.mfa.InitialFluxWorkflow( ...
                PointGenerator = generator, ...
                MDVPredictor = helpers.MDVPredictorStub());

            result = workflow.run( ...
                InitialFluxWorkflowContractTest.createInput());

            testCase.verifyTrue(result.IsCanceled);
            testCase.verifyFalse(result.IsError);

        end

    end

    methods (Static, Access = private)

        function input = createInput(options)

            arguments
                options.IterationCount (1, 1) double = 2
                options.UpperBounds double = [10; 1]
            end

            data = openmebius.mfa.MFAExperimentalData( ...
                ExperimentalMDV = 0.8, ...
                FragmentLabels = "M0", ...
                FragmentMask = true);
            input = openmebius.mfa.InitialFluxWorkflowInput( ...
                Model = helpers.InitialFluxModelStub(), ...
                IterationCount = options.IterationCount, ...
                RightHandSide = [5; 0], ...
                LowerBounds = [0; 0], ...
                UpperBounds = options.UpperBounds, ...
                SubstrateEMUs = {1}, ...
                ExperimentalData = data, ...
                OptimizationMDV = data.ExperimentalMDV, ...
                EffluxPenalty = openmebius.mfa.EffluxPenalty());

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
