classdef SubstrateEMUFactoryTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(SubstrateEMUFactoryTest.sourcePath());

        end

    end

    methods (Test)

        function buildsExperimentEMUInSortedSubstrateOrder(testCase)

            factory = openmebius.mfa.SubstrateEMUFactory();
            model = helpers.SubstrateEMUModelStub();
            experiments = SubstrateEMUFactoryTest.experiments();

            result = factory.fromExperiment( ...
                model, experiments, "E1");

            testCase.verifyEqual(result, [1, 10; 2, 20]);
            testCase.verifyEqual(model.PreparationCount, 1);

        end

        function buildsCustomPatternAndRemovesAnnotations(testCase)

            factory = openmebius.mfa.SubstrateEMUFactory();

            result = factory.fromPattern( ...
                helpers.SubstrateEMUModelStub(), ...
                SubstrateEMUFactoryTest.experiments(), ...
                {'B-label~custom', 'A-label~custom'});

            testCase.verifyEqual(result, [1, 10; 2, 20]);

        end

        function rejectsPatternCountMismatch(testCase)

            factory = openmebius.mfa.SubstrateEMUFactory();

            testCase.verifyError( ...
                @() factory.fromPattern( ...
                helpers.SubstrateEMUModelStub(), ...
                SubstrateEMUFactoryTest.experiments(), ...
                {'A-label'}), ...
                "OpenMebius2:SubstrateEMUFactory:" + ...
                "TracerDimensionMismatch");

        end

        function rejectsUnknownTracerDefinition(testCase)

            factory = openmebius.mfa.SubstrateEMUFactory();

            testCase.verifyError( ...
                @() factory.fromPattern( ...
                helpers.SubstrateEMUModelStub(), ...
                SubstrateEMUFactoryTest.experiments(), ...
                {'unknown', 'A-label'}), ...
                "OpenMebius2:SubstrateEMUFactory:" + ...
                "TracerDefinitionMismatch");

        end

        function rejectsMissingExperiment(testCase)

            factory = openmebius.mfa.SubstrateEMUFactory();

            testCase.verifyError( ...
                @() factory.fromExperiment( ...
                helpers.SubstrateEMUModelStub(), ...
                SubstrateEMUFactoryTest.experiments(), ...
                "missing"), ...
                "OpenMebius2:SubstrateEMUFactory:ExperimentNotFound");

        end

    end

    methods (Static, Access = private)

        function experiments = experiments()

            tracerTable = cell2table( ...
                {'B-label~0.25', 'A-label'}, ...
                VariableNames = {'B', 'A'}, ...
                RowNames = {'E1'});
            experiments = helpers.SubstrateEMUExperimentsStub( ...
                tracerTable);

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
