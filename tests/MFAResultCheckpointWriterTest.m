classdef MFAResultCheckpointWriterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAResultCheckpointWriterTest.sourcePath());

        end

    end

    methods (Test)

        function createsBackwardCompatibleIterationCheckpoint(testCase)

            writer = ...
                openmebius.infrastructure.result.MFAResultCheckpointWriter();
            checkpoint = writer.createIterationCheckpoint( ...
                3, ...
                MFAResultCheckpointWriterTest.createIterationResult(), ...
                [1, 2], ...
                TimestampUnix = 123.75);

            testCase.verifyEqual(checkpoint.FieldName, "fluxResult0003");
            testCase.verifyEqual(checkpoint.DataPath, "/fluxResult/0003");
            testCase.verifyEqual(checkpoint.Value.flux, [5; 2; 7]);
            testCase.verifyEqual(checkpoint.Value.fluxFwd, [3; 7]);
            testCase.verifyEqual(checkpoint.Value.RSS, 4.5);
            testCase.verifyEqual( ...
                checkpoint.Value.finiteDifferenceStepSize, 1e-5);
            testCase.verifyEqual( ...
                checkpoint.Value.finiteDifferenceStepSizeCandidates, ...
                [1e-4; 1e-5]);
            testCase.verifyEqual(checkpoint.Value.time, 123.75);

        end

        function writesIterationDatasetsAndTypes(testCase)

            repository = helpers.RecordingDatasetRepository();
            writer = ...
                openmebius.infrastructure.result.MFAResultCheckpointWriter( ...
                Repository = repository);
            checkpoint = writer.createIterationCheckpoint( ...
                3, ...
                MFAResultCheckpointWriterTest.createIterationResult(), ...
                [1, 2], ...
                TimestampUnix = 123.75);

            [isSuccess, message] = writer.writeIteration( ...
                "result.h5", checkpoint);

            testCase.verifyTrue(isSuccess, message);
            testCase.verifyEqual(repository.Paths(1), ...
                "/fluxResult/0003/flux");
            testCase.verifyEqual(repository.Paths(end), ...
                "/fluxResult/0003/time");
            testCase.verifyEqual(repository.Values{end}, int32(123.75));
            testCase.verifyEqual(repository.DataTypes(end), "int32");
            testCase.verifyEqual(numel(repository.Paths), 10);

        end

        function writesWorkflowSummary(testCase)

            repository = helpers.RecordingDatasetRepository();
            writer = ...
                openmebius.infrastructure.result.MFAResultCheckpointWriter( ...
                Repository = repository);

            [isSuccess, message] = writer.writeSummary( ...
                "result.h5", [1, 2], [2, 1], [1, 1, 0, 0], 3.84);

            testCase.verifyTrue(isSuccess, message);
            testCase.verifyEqual( ...
                repository.Paths, ...
                ["/RSS"; "/RSSIndex"; "/status"; "/threshold"]);
            testCase.verifyEqual(repository.Values{2}, int32([2, 1]));
            testCase.verifyEqual(repository.Values{3}, int8([1, 1, 0, 0]));
            testCase.verifyEqual( ...
                repository.DataTypes, ...
                ["double"; "int32"; "int8"; "double"]);

        end

        function stopsAtFirstRepositoryFailure(testCase)

            repository = helpers.RecordingDatasetRepository();
            repository.FailAt = 2;
            writer = ...
                openmebius.infrastructure.result.MFAResultCheckpointWriter( ...
                Repository = repository);
            checkpoint = writer.createIterationCheckpoint( ...
                1, MFAResultCheckpointWriterTest.createIterationResult());

            [isSuccess, message] = writer.writeIteration( ...
                "result.h5", checkpoint);

            testCase.verifyFalse(isSuccess);
            testCase.verifyEqual(numel(repository.Paths), 2);
            testCase.verifySubstring(message, repository.Paths(2));

        end

    end

    methods (Static, Access = private)

        function result = createIterationResult()

            search = struct( ...
                candidates = [1e-4; 1e-5], ...
                objectives = [5; 4.5], ...
                exitflags = [1; 1]);
            output = struct( ...
                fminconFiniteDifferenceStepSize = 1e-5, ...
                fminconFiniteDifferenceStepSizeSearch = search);
            result = openmebius.mfa.MFAIterationResult( ...
                IndependentValues = [5; 2; 7], ...
                Flux = [5; 2; 7], ...
                MDV = [0.2; 0.8], ...
                ObjectiveValue = 4.5, ...
                ExitFlag = 1, ...
                Output = output);

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
