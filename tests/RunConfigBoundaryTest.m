classdef RunConfigBoundaryTest < matlab.unittest.TestCase

    methods (Test)

        function appDoesNotLoadBatchTablesDirectly(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "RunConfig_exported.m")));
            directCalls = [ ...
                "Session.effluxTable", ...
                "Session.suggestionTable", ...
                "Session.instPoolTable", ...
                "Session.instTimePointTable", ...
                "Session.msFragmentSelections"];

            for call = directCalls
                testCase.verifyFalse(contains(source, call));
            end

            testCase.verifyFalse(contains(source, "uialert("));
            testCase.verifyFalse(contains(source, "Session.apply("));
            testCase.verifyFalse(contains(source, "Session.primaryConfig("));
            testCase.verifyFalse(contains(source, "MSFragmentTableMapper"));
            testCase.verifyTrue(contains(source, "RunConfigPresenter"));
            testCase.verifyTrue(contains(source, "RunConfigTableViewModel"));
            testCase.verifyTrue( ...
                contains(source, "BatchConfigurationController"));

        end

        function parentBuildsEditorBeforeChildApp(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "OpenMebius2_exported.m")));

            testCase.verifyTrue( ...
                contains(source, "editor = presenter.presentEditor(session)"));
            testCase.verifyTrue( ...
                contains(source, ...
                    "session, presenter, editor, controller"));
            testCase.verifyTrue( ...
                contains(source, "BatchConfigurationController()"));

        end

    end % methods (Test)

end % classdef
