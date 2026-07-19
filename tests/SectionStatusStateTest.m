classdef SectionStatusStateTest < matlab.unittest.TestCase

    methods (Test)

        function updateReturnsRowsForCurrentState(testCase)
            state = openmebius.presentation.status.SectionStatusState();

            rows = state.update("model", "finished");

            testCase.verifyNumElements(rows, 4);
            testCase.verifyTrue(contains(string(rows{1}), ...
                "Model loaded successfully"));
        end

        function resetDiscardsPreviousValues(testCase)
            state = openmebius.presentation.status.SectionStatusState();
            state.update("batch", "error");

            rows = state.reset();

            testCase.verifyTrue(contains(string(rows{3}), ...
                "Batch not started"));
        end

    end

end
