classdef InstationaryInputFactoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(InstationaryInputFactoryTest.sourcePath());

        end

    end

    methods (Test)

        function alignsNamedPoolSizesToModelOrder(testCase)

            model = helpers.SteadyStateModelStub();
            model.Metabolites = ["B"; "A"];
            config = struct( ...
                poolMetabolite = ["A"; "B"], ...
                poolSize = [2; 4], ...
                timePoints = [0; 1; 2]);

            input = openmebius.mfa.InstationaryInputFactory() ...
                .create(model, config);

            testCase.verifyEqual(input.PoolSizes, [4; 2]);
            testCase.verifyEqual(input.TimePoints, [0; 1; 2]);

        end

        function acceptsPoolSizesAlreadyInModelOrder(testCase)

            model = helpers.SteadyStateModelStub();
            config = struct( ...
                poolSize = [2; 4], ...
                timePoints = [0; 1]);

            input = openmebius.mfa.InstationaryInputFactory() ...
                .create(model, config);

            testCase.verifyEqual(input.PoolSizes, [2; 4]);

        end

        function reportsMissingMetabolitePoolSize(testCase)

            model = helpers.SteadyStateModelStub();
            config = struct( ...
                poolMetabolite = "A", ...
                poolSize = 2, ...
                timePoints = [0; 1]);

            testCase.verifyError( ...
                @() openmebius.mfa.InstationaryInputFactory() ...
                .create(model, config), ...
                "OpenMebius2:InstationaryInputFactory:MissingPoolSizes");

        end

        function reportsPositionalPoolSizeCountMismatch(testCase)

            model = helpers.SteadyStateModelStub();
            config = struct( ...
                poolSize = 2, ...
                timePoints = [0; 1]);

            testCase.verifyError( ...
                @() openmebius.mfa.InstationaryInputFactory() ...
                .create(model, config), ...
                "OpenMebius2:InstationaryInputFactory:" + ...
                "PoolSizeCountMismatch");

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
