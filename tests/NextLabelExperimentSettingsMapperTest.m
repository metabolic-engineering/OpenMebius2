classdef NextLabelExperimentSettingsMapperTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(NextLabelExperimentSettingsMapperTest.sourcePath());

        end

    end

    methods (Test)

        function mapsBatchSuggestionConfiguration(testCase)

            config = struct( ...
                suggestionTable = ["A", "B"; "C", "D"], ...
                suggestionTableRowNames = ["first"; "second"], ...
                suggestionTableVarNames = ["T1", "T2"]);
            settings = openmebius.application.analysis ...
                .NextLabelExperimentSettingsMapper ...
                .fromBatchConfig(config);

            testCase.verifyEqual( ...
                settings.Patterns, ["A", "B"; "C", "D"]);
            testCase.verifyEqual( ...
                settings.PatternNames, ["first"; "second"]);
            testCase.verifyEqual(settings.TracerNames, ["T1", "T2"]);
            testCase.verifyEqual(settings.patternCount(), 2);
            testCase.verifyTrue(settings.isCompletePattern(1));

        end

        function convertsLegacyEmptyCellsToIncompletePatterns(testCase)

            config = struct;
            config.suggestionTable = {'A'; []};
            config.suggestionTableRowNames = ["valid"; "empty"];
            config.suggestionTableVarNames = "Tracer";
            settings = openmebius.application.analysis ...
                .NextLabelExperimentSettingsMapper ...
                .fromBatchConfig(config);

            testCase.verifyEqual(settings.Patterns, ["A"; ""]);
            testCase.verifyTrue(settings.isCompletePattern(1));
            testCase.verifyFalse(settings.isCompletePattern(2));

        end

        function allowsMissingOptionalPatternNames(testCase)

            settings = openmebius.application.analysis ...
                .NextLabelExperimentSettingsMapper ...
                .fromBatchConfig(struct( ...
                suggestionTable = "A", ...
                suggestionTableVarNames = "Tracer"));

            testCase.verifyEmpty(settings.PatternNames);
            testCase.verifyEqual(settings.Patterns, "A");

        end

        function treatsMissingValuesAsIncompletePatterns(testCase)

            settings = openmebius.mfa.NextLabelExperimentSettings( ...
                Patterns = ["A"; missing], ...
                TracerNames = "Tracer");

            testCase.verifyTrue(settings.isCompletePattern(1));
            testCase.verifyFalse(settings.isCompletePattern(2));

        end

        function rejectsColumnNameMismatch(testCase)

            config = struct( ...
                suggestionTable = ["A", "B"], ...
                suggestionTableVarNames = "Tracer");

            testCase.verifyError( ...
                @() openmebius.application.analysis ...
                .NextLabelExperimentSettingsMapper ...
                .fromBatchConfig(config), ...
                "OpenMebius2:NextLabelExperimentSettings:" + ...
                "TracerCountMismatch");

        end

        function rejectsDuplicateTracerNames(testCase)

            config = struct( ...
                suggestionTable = ["A", "B"], ...
                suggestionTableVarNames = ["Tracer", "Tracer"]);

            testCase.verifyError( ...
                @() openmebius.application.analysis ...
                .NextLabelExperimentSettingsMapper ...
                .fromBatchConfig(config), ...
                "OpenMebius2:NextLabelExperimentSettings:" + ...
                "DuplicateTracerName");

        end

        function aggregateMapperComposesConfidenceSettings(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.suggestionTable = "A";
            config.suggestionTableRowNames = "candidate";
            config.suggestionTableVarNames = "Tracer";
            settings = openmebius.application.analysis ...
                .NextFluxExperimentRunSettingsMapper ...
                .fromBatchConfig(config);

            testCase.verifyClass( ...
                settings.ConfidenceIntervalRunSettings, ...
                ['openmebius.application.analysis.' ...
                'MFAConfidenceIntervalRunSettings']);
            testCase.verifyEqual(settings.NextLabelSettings.Patterns, "A");

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
