classdef BatchIdentityTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            sourcePath = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');
            addpath(sourcePath);

        end

    end

    methods (Test)

        function createsStableOpaqueIdFormat(testCase)

            id = openmebius.domain.batch.BatchIdentity.newId();

            testCase.verifyMatches(id, "^bat_[0-9a-f]{32}$");

        end

        function ignoresLegacyRandomAndRuntimeFields(testCase)

            configA = openmebius.domain.batch.BatchConfig.defaultConfig();
            configA.random = 0.125;
            configB = configA;
            configB.random = 0.875;
            configB.status = 'finished';
            configB.deleteResultFile = false;

            hashA = openmebius.domain.batch.BatchIdentity.contentHash( ...
                configA, ...
                "model-hash", ...
                ["exp-a"; "exp-b"], ...
                ["hash-a"; "hash-b"]);
            hashB = openmebius.domain.batch.BatchIdentity.contentHash( ...
                configB, ...
                "model-hash", ...
                ["exp-a"; "exp-b"], ...
                ["hash-a"; "hash-b"]);

            testCase.verifyEqual(hashA, hashB);
            testCase.verifyMatches(hashA, "^sha256:[0-9a-f]{64}$");

        end

        function changesWhenSemanticConfigChanges(testCase)

            configA = openmebius.domain.batch.BatchConfig.defaultConfig();
            configB = configA;
            configB.GA.seed = configA.GA.seed + 1;

            hashA = openmebius.domain.batch.BatchIdentity.contentHash( ...
                configA, "model-hash", "exp-a", "hash-a");
            hashB = openmebius.domain.batch.BatchIdentity.contentHash( ...
                configB, "model-hash", "exp-a", "hash-a");

            testCase.verifyNotEqual(hashA, hashB);

        end

        function changesWhenSourceContentChanges(testCase)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            baseline = openmebius.domain.batch.BatchIdentity.contentHash( ...
                config, "model-a", "exp-a", "experiment-a");
            changedModel = openmebius.domain.batch.BatchIdentity.contentHash( ...
                config, "model-b", "exp-a", "experiment-a");
            changedExperiment = openmebius.domain.batch.BatchIdentity.contentHash( ...
                config, "model-a", "exp-a", "experiment-b");

            testCase.verifyNotEqual(baseline, changedModel);
            testCase.verifyNotEqual(baseline, changedExperiment);

        end

    end

end
