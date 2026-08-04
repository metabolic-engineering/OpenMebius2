classdef BatchConfigurationControllerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function appliesTypedRequest(testCase)

            batch = helpers.RunConfigBatchStub();
            session = BatchConfigurationControllerTest.createSession(batch);
            request = BatchConfigurationControllerTest.createRequest( ...
                batch, 52);
            controller = openmebius.application.batch ...
                .BatchConfigurationController();

            outcome = controller.apply(session, @() request);

            testCase.verifyTrue(outcome.isSuccess());
            testCase.verifyEqual(batch.Config.iteration, 52);
            testCase.verifyEqual(batch.FragmentUpdateCount, 1);

        end

        function capturesRequestFactoryFailure(testCase)

            batch = helpers.RunConfigBatchStub();
            session = BatchConfigurationControllerTest.createSession(batch);
            controller = openmebius.application.batch ...
                .BatchConfigurationController();

            outcome = controller.apply( ...
                session, ...
                @BatchConfigurationControllerTest.failRequestFactory);

            testCase.verifyTrue(outcome.isFailure());
            testCase.verifyEqual( ...
                string(outcome.Exception.identifier), ...
            "OpenMebius2:Test:RequestFailed");
            testCase.verifyEqual(batch.ConfigUpdateCount, 0);

        end

        function capturesApplyFailureAfterRollback(testCase)

            batch = helpers.RunConfigBatchStub();
            batch.FailFragmentUpdate = true;
            originalIteration = batch.Config.iteration;
            session = BatchConfigurationControllerTest.createSession(batch);
            request = BatchConfigurationControllerTest.createRequest( ...
                batch, 73);
            controller = openmebius.application.batch ...
                .BatchConfigurationController();

            outcome = controller.apply(session, @() request);

            testCase.verifyTrue(outcome.isFailure());
            testCase.verifyEqual(batch.Config.iteration, originalIteration);
            testCase.verifyEqual(batch.ConfigUpdateCount, 2);

        end

    end % methods (Test)

    methods (Static, Access = private)

        function session = createSession(batch)

            session = openmebius.application.batch ...
                .BatchConfigurationSession(batch, [], "batch-a");

        end

        function request = createRequest(batch, iteration)

            config = batch.Config;
            config.iteration = iteration;
            selections = batch.getBatchMSFragmentSelections("batch-a");
            request = openmebius.application.batch ...
                .BatchConfigurationApplyRequest(config, selections);

        end

        function request = failRequestFactory()

            error( ...
                "OpenMebius2:Test:RequestFailed", ...
            "Request creation failed.");
            request = []; %#ok<UNRCH>

        end

    end % methods (Static, Access = private)

end % classdef
