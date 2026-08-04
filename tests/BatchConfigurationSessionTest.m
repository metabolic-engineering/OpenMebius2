classdef BatchConfigurationSessionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function appliesConfigurationAndFragmentsTogether(testCase)

            batch = helpers.RunConfigBatchStub();
            session = BatchConfigurationSessionTest.createSession(batch);
            config = session.primaryConfig();
            config.iteration = 41;
            selections = batch.getBatchMSFragmentSelections("batch-a");

            session.apply(config, selections, []);

            testCase.verifyEqual(batch.Config.iteration, 41);
            testCase.verifyEqual(batch.ConfigUpdateCount, 1);
            testCase.verifyEqual(batch.FragmentUpdateCount, 1);

        end

        function rollsBackConfigurationWhenApplyFails(testCase)

            batch = helpers.RunConfigBatchStub();
            batch.FailFragmentUpdate = true;
            session = BatchConfigurationSessionTest.createSession(batch);
            config = session.primaryConfig();
            originalIteration = config.iteration;
            config.iteration = 99;
            selections = batch.getBatchMSFragmentSelections("batch-a");

            testCase.verifyError( ...
                @() session.apply(config, selections, []), ...
                "OpenMebius2:Test:FragmentUpdateFailed");
            testCase.verifyEqual( ...
                batch.Config.iteration, originalIteration);
            testCase.verifyEqual(batch.ConfigUpdateCount, 2);

        end

        function rejectsDuplicateBatchIds(testCase)

            batch = helpers.RunConfigBatchStub();

            testCase.verifyError( ...
                @() openmebius.application.batch ...
                    .BatchConfigurationSession( ...
                        batch, [], ["batch-a"; "batch-a"]), ...
                "OpenMebius2:BatchConfigurationSession:" + ...
                    "DuplicateBatchIds");

        end

    end % methods (Test)

    methods (Static, Access = private)

        function session = createSession(batch)

            session = openmebius.application.batch ...
                .BatchConfigurationSession( ...
                    batch, [], "batch-a");

        end

    end % methods (Static, Access = private)

end % classdef
