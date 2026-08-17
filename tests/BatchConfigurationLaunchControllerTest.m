classdef BatchConfigurationLaunchControllerTest < ...
        matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function preparesConfigurationSession(testCase)

            controller = openmebius.application.batch ...
                .BatchConfigurationLaunchController();
            request = openmebius.application.batch ...
                .BatchConfigurationLaunchRequest( ...
                ["batch-a"; "batch-b"]);

            outcome = controller.prepare( ...
                helpers.RunConfigBatchStub(), ...
                helpers.MSViewExperimentsStub(), ...
                @() request);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyClass( ...
                outcome.Session, ...
                ['openmebius.application.batch.' ...
                'BatchConfigurationSession']);
            testCase.verifyEqual( ...
                outcome.Session.BatchIds, ["batch-a"; "batch-b"]);

        end

        function capturesRequestFactoryFailure(testCase)

            controller = openmebius.application.batch ...
                .BatchConfigurationLaunchController();

            outcome = controller.prepare( ...
                helpers.RunConfigBatchStub(), [], ...
                @BatchConfigurationLaunchControllerTest.failRequest);

            testCase.verifyTrue(outcome.isFailure());
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:Test:LaunchRequestFailed");

        end

        function synchronizesPendingDescriptionBeforeLaunch(testCase)

            batch = helpers.RunConfigBatchStub();
            tableData = batch.getBatchForGUI();
            tableData.Description = "Description edited in Run table";
            request = openmebius.application.batch ...
                .BatchConfigurationLaunchRequest( ...
                "batch-a", TableData = tableData);
            controller = openmebius.application.batch ...
                .BatchConfigurationLaunchController();

            outcome = controller.prepare( ...
                batch, [], @() request);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual( ...
                batch.Description, ...
                "Description edited in Run table");
            testCase.verifyEqual(batch.MetadataUpdateCount, 1);

        end

        function rejectsUnexpectedRequestType(testCase)

            controller = openmebius.application.batch ...
                .BatchConfigurationLaunchController();

            outcome = controller.prepare( ...
                helpers.RunConfigBatchStub(), [], @() struct());

            testCase.verifyTrue(outcome.isFailure());
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
                "OpenMebius2:" + ...
                "BatchConfigurationLaunchController:InvalidRequest");

        end

    end % methods (Test)

    methods (Static, Access = private)

        function request = failRequest()

            error( ...
                "OpenMebius2:Test:LaunchRequestFailed", ...
                "Launch request failed.");
            request = []; %#ok<UNRCH>

        end

    end % methods (Static, Access = private)

end % classdef
