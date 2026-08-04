classdef ResultRepositoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourceToPath(~)

            addpath(ResultRepositoryTest.sourcePath());

        end

    end

    methods (Test)

        function openCreatesResultObject(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                ResultRepositoryTest.removeDirectory(resultDirectory));

            repository = openmebius.infrastructure.result.ResultRepository();
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(resultDirectory);

            result = repository.open(resultLocation);

            testCase.verifyClass( ...
                result, ...
            "openmebius.application.result.ResultCatalog");
            testCase.verifyEqual( ...
                result.getResultLocation().Directory, ...
                resultDirectory);

            clear cleanup

        end

        function openRejectsMissingDirectory(testCase)

            repository = openmebius.infrastructure.result.ResultRepository();
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(fullfile(tempdir, "missing-openmebius-result-repo"));

            testCase.verifyError( ...
                @() repository.open(resultLocation), ...
            "OpenMebius2:ResultRepository:DirectoryNotFound");

        end

        function openedResultDoesNotExposeLegacyStatusProperties(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                ResultRepositoryTest.removeDirectory(resultDirectory));

            repository = openmebius.infrastructure.result.ResultRepository();
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(resultDirectory);

            result = repository.open(resultLocation);

            testCase.verifyFalse(isprop(result, "isError"));
            testCase.verifyFalse(isprop(result, "statusMsg"));

            clear cleanup

        end

        function openedResultUsesInjectedHdf5Repository(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                ResultRepositoryTest.removeDirectory(resultDirectory));

            reader = helpers.RecordingResultDataRepository();
            repository = openmebius.infrastructure.result.ResultRepository( ...
                Hdf5ResultRepository = reader);
            resultLocation = openmebius.domain.result.ResultLocation ...
                .fromDirectory(resultDirectory);
            resultId = "delegated-result";
            fileId = fopen(resultLocation.resultFile(resultId), "w");
            testCase.assertGreaterThan(fileId, 0);
            fclose(fileId);

            result = repository.open(resultLocation);
            data = result.loadResultFile( ...
                resultId, ...
                readstatus = [true, false, false, false]);

            testCase.verifyEqual(data, reader.ResultData);
            testCase.verifyEqual(reader.ReadCount, 1);
            testCase.verifyEqual(reader.ResultLocation, resultLocation);
            testCase.verifyEqual(reader.ResultId, resultId);
            testCase.verifyEqual( ...
                reader.ReadStatus, ...
                [true, false, false, false]);

            clear cleanup

        end

        function loadFailureIsReportedThroughCoreMessage(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            observer = helpers.AnalysisNotificationObserverStub();
            result = openmebius.application.result.ResultCatalog( ...
                resultDirectory, ...
                NotificationReporter = ...
                @(message) observer.publish(message));
            rmdir(resultDirectory, 's');

            data = result.loadResultFile("missing");

            testCase.verifyEmpty(data);
            testCase.verifyEqual(observer.EventCount, 2);
            testCase.verifyClass( ...
                observer.LastEvent, ...
            'openmebius.core.notification.Message');
            testCase.verifyEqual(observer.LastEvent.Level, "error");

        end

        function writeExcelTableCanBeReadBack(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                ResultRepositoryTest.removeDirectory(resultDirectory));

            repository = openmebius.infrastructure.result.ResultRepository();
            pathFile = fullfile(resultDirectory, "result.xlsx");
            sourceTable = table( ...
                ["r1"; "r2"], ...
                [1.0; 2.0], ...
                VariableNames = ["Reaction", "Flux"]);

            [isSuccess, msg] = repository.writeExcelTable( ...
                pathFile, ...
                sourceTable, ...
                "Overview", ...
                WriteRowNames = false);

            testCase.verifyTrue(isSuccess, msg);
            loaded = readtable(pathFile, Sheet = "Overview");
            testCase.verifyEqual(string(loaded.Reaction), sourceTable.Reaction);
            testCase.verifyEqual(loaded.Flux, sourceTable.Flux);

            clear cleanup

        end

        function writeCsvTableCanBeReadBack(testCase)

            resultDirectory = string(tempname);
            mkdir(resultDirectory);
            cleanup = onCleanup(@() ...
                ResultRepositoryTest.removeDirectory(resultDirectory));

            repository = openmebius.infrastructure.result.ResultRepository();
            pathFile = fullfile(resultDirectory, "result.csv");
            sourceTable = table( ...
                ["r1"; "r2"], ...
                [1.0; 2.0], ...
                VariableNames = ["Reaction", "Flux"]);

            [isSuccess, msg] = repository.writeCsvTable( ...
                pathFile, ...
                sourceTable, ...
                WriteRowNames = false);

            testCase.verifyTrue(isSuccess, msg);
            loaded = readtable(pathFile);
            testCase.verifyEqual(string(loaded.Reaction), sourceTable.Reaction);
            testCase.verifyEqual(loaded.Flux, sourceTable.Flux);

            clear cleanup

        end

        function gridSearchExportContainsProfileSheets(testCase)

            repositoryRoot = ResultRepositoryTest.repositoryRoot();
            resultDirectory = fullfile( ...
                repositoryRoot, "tutorial", ...
                "ecoli_grid_search", "results");
            outputDirectory = string(tempname);
            mkdir(outputDirectory);
            cleanup = onCleanup(@() ...
                ResultRepositoryTest.removeDirectory(outputDirectory));
            result = openmebius.application.result.ResultCatalog( ...
                resultDirectory);
            batchID = "bat_dd0eff6798474f24b58b6657e5dd0354";
            batchName = "GridSearch";

            result.saveResultData( ...
                batchID, batchName, outputDirectory, "xlsx");

            workbook = fullfile( ...
                outputDirectory, ...
                "result_" + batchName + "_" + batchID + ".xlsx");
            testCase.assertTrue(isfile(workbook));
            sheets = string(sheetnames(workbook));
            testCase.verifyTrue(any(sheets == "GridSearch"));
            testCase.verifyTrue(any(sheets == "GS_001_r2"));
            profileSheets = sheets(startsWith(sheets, "GS_"));
            testCase.verifyNumElements(profileSheets, 24);
            testCase.verifyTrue(any(profileSheets == "GS_024_r25"));
            profile = readtable( ...
                workbook, Sheet = "GS_001_r2");
            testCase.verifyEqual( ...
                string(profile.Properties.VariableNames), ...
                ["FixedFlux", "RSS"]);
            testCase.verifyGreaterThan(height(profile), 0);
            testCase.verifyTrue(issorted(profile.FixedFlux));
            testCase.verifyEqual( ...
                numel(unique(profile.FixedFlux)), height(profile));

            clear cleanup

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile(ResultRepositoryTest.repositoryRoot(), "src");

        end

        function path = repositoryRoot()

            path = fileparts(fileparts(mfilename("fullpath")));

        end

        function removeDirectory(directory)

            if isfolder(directory)
                rmdir(directory, "s");
            end

        end

    end

end
