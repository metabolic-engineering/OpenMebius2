classdef ResultSuggestionServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function loadsAndEnrichesSuggestion(testCase)

            workspace = helpers.ResultSuggestionWorkspaceStub();
            workspace.Suggestion = struct("Score", 0.5);
            service = openmebius.application.result ...
                .ResultSuggestionService();

            result = service.load( ...
                workspace, "batch-a", "Batch A");

            testCase.verifyTrue(workspace.Called);
            testCase.verifyEqual(workspace.BatchID, "batch-a");
            testCase.verifyEqual(result.BatchID, "batch-a");
            testCase.verifyEqual(result.BatchName, "Batch A");
            testCase.verifyEqual(result.Suggestion.Score, 0.5);
            testCase.verifyEqual( ...
                result.Suggestion.sampleName, "Batch A");
            testCase.verifyEqual( ...
                result.Suggestion.batchID, "batch-a");

        end

        function requiresExactlyOneSelection(testCase)

            service = openmebius.application.result ...
                .ResultSuggestionService();
            workspace = helpers.ResultSuggestionWorkspaceStub();

            testCase.verifyError( ...
                @() service.load( ...
                workspace, strings(0, 1), strings(0, 1)), ...
                "OpenMebius2:ResultSuggestion:SelectionRequired");
            testCase.verifyError( ...
                @() service.load( ...
                workspace, ["a"; "b"], ["A"; "B"]), ...
                "OpenMebius2:ResultSuggestion:SelectionRequired");
            testCase.verifyFalse(workspace.Called);

        end

        function reportsUnavailableSuggestion(testCase)

            service = openmebius.application.result ...
                .ResultSuggestionService();
            workspace = helpers.ResultSuggestionWorkspaceStub();
            workspace.IsAvailable = false;

            testCase.verifyError( ...
                @() service.load(workspace, "batch-a", "Batch A"), ...
                "OpenMebius2:ResultSuggestion:NotAvailable");

        end

        function rejectsInvalidSuggestionData(testCase)

            service = openmebius.application.result ...
                .ResultSuggestionService();
            workspace = helpers.ResultSuggestionWorkspaceStub();
            workspace.Suggestion = struct.empty;

            testCase.verifyError( ...
                @() service.load(workspace, "batch-a", "Batch A"), ...
                "OpenMebius2:ResultSuggestion:InvalidData");

        end

    end % methods (Test)

end % classdef
