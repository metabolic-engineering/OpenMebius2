classdef BatchConfigTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            sourcePath = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');
            addpath(sourcePath);

        end % addSourcePath

    end % methods

    methods (Test)

        function identifiesFinishedAndFailedAsTerminal(testCase)

            testCase.verifyEqual( ...
                openmebius.domain.batch.BatchConfig.isTerminalStatus( ...
                ["ready", "finished", "error", "failed"]), ...
                [false, true, true, true]);

        end

        function normalizeFillsMissingFieldsAndValidates(testCase)

            config = openmebius.domain.batch.BatchConfig.normalize( ...
                struct('iteration', 7));

            testCase.verifyEqual(config.iteration, 7);
            testCase.verifyTrue( ...
                config.initialFlux.restrictFreeEffluxSeeds);
            testCase.verifyEqual( ...
                config.initialFlux.freeEffluxSeedSigmaMultiplier, 3);
            testCase.verifyEqual(config.status, 'ready');
            testCase.verifyTrue(isfield(config, 'fmincon'));
            testCase.verifyFalse(config.fmincon.enforceFluxBounds);
            testCase.verifyTrue(isfield(config, 'GA'));
            testCase.verifyTrue(isfield(config, 'CIConf'));
            testCase.verifyTrue( ...
                isfield(config.CIConf.grid, 'reactions'));
            testCase.verifyEqual( ...
                config.CIConf.grid.intervalMode, 'automatic');
            testCase.verifyEqual( ...
                config.CIConf.grid.executionMode, 'parallel');
            testCase.verifyEqual(config.CIConf.grid.workerCount, 58);
            testCase.verifyEqual( ...
                config.CIConf.grid.maximumTrial, 15);
            testCase.verifyEqual( ...
                config.CIConf.grid.minimumFluxRange, 1e-6);
            testCase.verifyTrue(isfield(config, 'INSTMFA'));

        end % normalizeFillsMissingFieldsAndValidates

        function validateRejectsInvalidFluxBoundEnforcement(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.fmincon.enforceFluxBounds = 2;

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidLogical');

        end

        function normalizeMigratesLegacyGridMode(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.grid = rmfield( ...
                config.CIConf.grid, ...
                {'intervalMode', 'executionMode'});
            config.CIConf.grid.isParallel = false;

            actual = openmebius.domain.batch.BatchConfig.normalize(config);

            testCase.verifyEqual( ...
                actual.CIConf.grid.intervalMode, 'fixed-delta');
            testCase.verifyEqual( ...
                actual.CIConf.grid.executionMode, 'parallel');
            testCase.verifyFalse( ...
                isfield(actual.CIConf.grid, 'isParallel'));

        end % normalizeMigratesLegacyGridMode

        function validateRejectsInvalidIteration(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.iteration = 0;

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidPositiveInteger');

        end % validateRejectsInvalidIteration

        function validateRejectsInvalidInitialFluxRestriction(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.initialFlux.restrictFreeEffluxSeeds = 2;

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidLogical');

        end

        function validateRejectsInvalidInitialFluxSigma(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.initialFlux.freeEffluxSeedSigmaMultiplier = 0;

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidPositiveNumber');

        end

        function validateRejectsUnknownAlgorithm(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.algorithm = 'not-an-algorithm';

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidMember');

        end % validateRejectsUnknownAlgorithm

        function validateRejectsInvalidStatus(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.status = 'running';

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidMember');

        end % validateRejectsInvalidStatus

        function validateRejectsInvalidFluxBounds(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.fluxLB = 10;
            config.fluxUB = 1;

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidFluxBounds');

        end % validateRejectsInvalidFluxBounds

        function validateRejectsInvalidNestedCIConfig(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.MC.iteration = -1;

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidPositiveInteger');

        end % validateRejectsInvalidNestedCIConfig

        function validateRejectsUnknownGridIntervalMode(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.grid.intervalMode = 'adaptive';

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidMember');

        end % validateRejectsUnknownGridIntervalMode

        function validateRejectsUnknownGridExecutionMode(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.grid.executionMode = 'distributed';

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidMember');

        end % validateRejectsUnknownGridExecutionMode

        function validateRejectsInvalidGridWorkerCount(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.grid.workerCount = 0;

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidPositiveInteger');

        end % validateRejectsInvalidGridWorkerCount

        function validateRejectsInvalidGridMaximumTrial(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.grid.maximumTrial = 0;

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidPositiveInteger');

        end % validateRejectsInvalidGridMaximumTrial

        function validateRejectsNegativeMinimumFluxRange(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.grid.minimumFluxRange = -eps;

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidNonnegativeNumber');

        end % validateRejectsNegativeMinimumFluxRange

        function validateRejectsOddAutomaticGridPointCount(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.grid.points = 9;

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:' + ...
                "AutomaticGridPointCountMustBeEven");

        end % validateRejectsOddAutomaticGridPointCount

        function validateRejectsMismatchedGridReactionValues(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.CIConf.grid.reactions.select = [true; false];
            config.CIConf.grid.reactions.id = "R1";
            config.CIConf.grid.reactions.reaction = ["A -> B"; "B -> C"];

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:GridReactionSizeMismatch');

        end % validateRejectsMismatchedGridReactionValues

        function validateRejectsInvalidLogical(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.isCalcCI = 2;

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidLogical');

        end % validateRejectsInvalidLogical

        function validateAllowsUnsetEffluxStandardDeviation(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.efflux.selection = false;
            config.efflux.substrate = "A";
            config.efflux.substrateSD = NaN;

            testCase.verifyWarningFree( ...
                @() openmebius.domain.batch.BatchConfig.validate(config));

        end % validateAllowsUnsetEffluxStandardDeviation

        function validateRejectsInfiniteEffluxStandardDeviation(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.efflux.selection = true;
            config.efflux.substrate = "A";
            config.efflux.substrateSD = Inf;

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
                'OpenMebius2:BatchConfig:InvalidFiniteNumber');

        end % validateRejectsInfiniteEffluxStandardDeviation

        function normalizeRestoresJsonNullGrowthRateSD(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.efflux.muSD = [];

            normalized = openmebius.domain.batch.BatchConfig ...
                .normalize(config);

            testCase.verifyTrue(isnan(normalized.efflux.muSD));

        end % normalizeRestoresJsonNullGrowthRateSD

        function mapperRejectsInvalidBatchConfig(testCase)

            batchData = struct( ...
                'id', "batch-id-1", ...
                'name', "batch-name-1", ...
                'exp', "exp-1", ...
                'description', "invalid config test", ...
                'config', struct('iteration', 0));

            testCase.verifyError( ...
                @() openmebius.infrastructure.batch.BatchJsonMapper.toTable( ...
                batchData), ...
                'OpenMebius2:BatchConfig:InvalidPositiveInteger');

        end % mapperRejectsInvalidBatchConfig

    end % methods

end % classdef
