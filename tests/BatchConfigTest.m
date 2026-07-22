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

        function normalizeFillsMissingFieldsAndValidates(testCase)

            config = openmebius.domain.batch.BatchConfig.normalize( ...
                struct('iteration', 7));

            testCase.verifyEqual(config.iteration, 7);
            testCase.verifyEqual(config.status, 'ready');
            testCase.verifyTrue(isfield(config, 'fmincon'));
            testCase.verifyTrue(isfield(config, 'GA'));
            testCase.verifyTrue(isfield(config, 'CIConf'));
            testCase.verifyTrue( ...
                isfield(config.CIConf.grid, 'reactions'));
            testCase.verifyTrue(isfield(config, 'INSTMFA'));

        end % normalizeFillsMissingFieldsAndValidates

        function validateRejectsInvalidIteration(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            config.iteration = 0;

            testCase.verifyError( ...
                @() openmebius.domain.batch.BatchConfig.validate(config), ...
            'OpenMebius2:BatchConfig:InvalidPositiveInteger');

        end % validateRejectsInvalidIteration

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
