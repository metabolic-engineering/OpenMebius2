classdef ResultInformationServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function loadsSavedBatchInformation(testCase)

            workspace = helpers.ResultInformationWorkspaceStub();
            workspace.Data = ResultInformationServiceTest.resultData();
            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.iteration = 12;
            config.numExperiments = 2;
            config.perturbateEfflux = true;
            config.efflux.selection = [true; false];
            config.efflux.substrate = ["glucose"; "acetate"];
            config.efflux.substrateSD = [0.1; 0.2];
            config.efflux.muSelection = true;
            config.efflux.muSD = 0.05;
            savedConfig = openmebius.domain.batch.BatchIdentity ...
                .semanticConfig(config);
            workspace.Snapshot = struct( ...
                ID = "batch-1", ...
                Name = "Saved name", ...
                Description = "Saved description", ...
                Experiments = ["exp-a"; "exp-b"], ...
                ConfigJson = string(jsonencode(savedConfig)), ...
                StartedAtUtc = "2026-08-18T01:02:03.000Z", ...
                FinishedAtUtc = "2026-08-18T01:03:05.500Z");
            service = openmebius.application.result ...
                .ResultInformationService();

            information = service.load( ...
                workspace, "batch-1", "Current name", 3);

            testCase.verifyEqual(information.BatchName, "Saved name");
            testCase.verifyEqual( ...
                information.Description, "Saved description");
            testCase.verifyEqual( ...
                information.ExperimentNames, ["exp-a"; "exp-b"]);
            testCase.verifyEqual(information.ElapsedSeconds, 62.5, ...
                AbsTol = 1e-9);
            testCase.verifyTrue(information.SettingsAvailable);
            testCase.verifyTrue(any(startsWith( ...
                information.DifferentSettings, "iteration:")));
            testCase.verifyFalse(any(startsWith( ...
                information.DifferentSettings, ...
                "fmincon.finiteDifferenceStepSizeSearch.candidates:")));
            testCase.verifyFalse(any(contains( ...
                information.DifferentSettings, ": [] (default: [])")));
            testCase.verifyEqual( ...
                information.MDVDegreesOfFreedom, 4);
            testCase.verifyEqual( ...
                information.EffluxDegreesOfFreedom, 2);
            testCase.verifyEqual( ...
                information.ModelDegreesOfFreedom, 3);
            testCase.verifyEqual( ...
                information.MDVRSSContribution, 8, AbsTol = 1e-9);
            testCase.verifyEqual( ...
                information.EffluxRSSContribution, 2, AbsTol = 1e-9);
            testCase.verifyEqual(information.ChiSquareThreshold, 9.49);

        end

        function rejectsMissingOrMultipleSelection(testCase)

            service = openmebius.application.result ...
                .ResultInformationService();
            workspace = helpers.ResultInformationWorkspaceStub();

            testCase.verifyError( ...
                @() service.load( ...
                workspace, strings(0, 1), strings(0, 1), 3), ...
                "OpenMebius2:ResultInformation:SelectionRequired");
            testCase.verifyError( ...
                @() service.load( ...
                workspace, ["a"; "b"], ["A"; "B"], 3), ...
                "OpenMebius2:ResultInformation:SelectionRequired");

        end

        function supportsLegacyResultWithoutMetadata(testCase)

            workspace = helpers.ResultInformationWorkspaceStub();
            workspace.Data = ResultInformationServiceTest.resultData();
            service = openmebius.application.result ...
                .ResultInformationService();

            information = service.load( ...
                workspace, "batch-1", "Fallback name", 3);

            testCase.verifyEqual(information.BatchName, "Fallback name");
            testCase.verifyFalse(information.SettingsAvailable);
            testCase.verifyTrue(isnan(information.ElapsedSeconds));
            testCase.verifyFalse(information.HasEffluxContribution);

        end

    end % methods (Test)

    methods (Static, Access = private)

        function data = resultData()

            data = struct;
            data.MDVExp = [0.80, 0.70; 0.20, 0.30; ...
                0.60, 0.50; 0.40, 0.50];
            data.MDVExpName = ["A"; "A"; "B"; "B"];
            data.MDVFragMask = true(4, 1);
            data.RSS = [10, 12];
            data.RSSIdx = [1, 2];
            data.threshold = 9.49;
            data.fluxResult0001.MDV = [ ...
                0.81; 0.19; 0.61; 0.39; ...
                0.71; 0.29; 0.51; 0.49];

        end

    end % methods (Static, Access = private)

end % classdef
