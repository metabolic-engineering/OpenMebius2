classdef MFAInputValidatorTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAInputValidatorTest.sourcePath());

        end

    end

    methods (Test)

        function validatesAndAggregatesEffluxInputs(testCase)

            validator = openmebius.mfa.MFAInputValidator();
            model = helpers.MFAInputValidationModelStub();
            experiments = MFAInputValidatorTest.experiments( ...
                [0.1; 0.3], [10, 2; 14, 4]);

            result = validator.validateEfflux( ...
                model, ...
                experiments, ...
                ["E1"; "E2"], ...
                struct(perturbateEfflux = false));

            testCase.verifyTrue(result.IsValid);
            testCase.verifyEqual(result.Value.GrowthRate, 0.2, ...
                AbsTol = 1e-12);
            testCase.verifyEqual( ...
                result.Value.SubstrateList, ["A"; "B"]);
            testCase.verifyEqual(result.Value.Efflux, [12; 3]);
            testCase.verifyEmpty( ...
                result.Value.EffluxStandardDeviation);
            testCase.verifyEmpty(result.Value.EffluxFree);

        end

        function alignsPerturbationInputsBySubstrateName(testCase)

            validator = openmebius.mfa.MFAInputValidator();
            model = helpers.MFAInputValidationModelStub();
            experiments = MFAInputValidatorTest.experiments( ...
                [0.2; 0.2], [10, 2; 10, 2]);
            config = struct;
            config.perturbateEfflux = true;
            config.efflux = struct( ...
                substrate = ["B"; "A"], ...
                selection = [true; false], ...
                substrateSD = [0.5; 0.1]);

            result = validator.validateEfflux( ...
                model, experiments, ["E1"; "E2"], config);

            testCase.verifyTrue(result.IsValid);
            testCase.verifyEqual( ...
                result.Value.EffluxStandardDeviation, [0.1; 0.5]);
            testCase.verifyEqual( ...
                result.Value.EffluxFree, [false; true]);

        end

        function rejectsNonPositiveSelectedStandardDeviation(testCase)

            validator = openmebius.mfa.MFAInputValidator();
            model = helpers.MFAInputValidationModelStub();
            experiments = MFAInputValidatorTest.experiments( ...
                [0.2; 0.2], [10, 2; 10, 2]);
            config = struct;
            config.perturbateEfflux = true;
            config.efflux = struct( ...
                substrate = ["A"; "B"], ...
                selection = [true; false], ...
                substrateSD = [0; 0.5]);

            result = validator.validateEfflux( ...
                model, experiments, ["E1"; "E2"], config);

            testCase.verifyFalse(result.IsValid);
            testCase.verifyEqual( ...
                result.ErrorMessage, ...
                "Efflux standard deviation must be positive " + ...
                "for perturbation.");

        end

        function rejectsDuplicatedModelSubstrates(testCase)

            validator = openmebius.mfa.MFAInputValidator();
            model = helpers.MFAInputValidationModelStub();
            model.Substrates = ["A"; "A"];
            experiments = MFAInputValidatorTest.experiments( ...
                [0.2; 0.2], [10, 2; 10, 2]);

            result = validator.validateEfflux( ...
                model, experiments, ["E1"; "E2"], ...
                struct(perturbateEfflux = false));

            testCase.verifyFalse(result.IsValid);
            testCase.verifyEqual( ...
                result.ErrorMessage, "Substrates were duplicated.");

        end

        function reportsFragmentsContainingSelectedNaNValues(testCase)

            validator = openmebius.mfa.MFAInputValidator();

            result = validator.validateMDV( ...
                [0.2, 0.3; NaN, 0.5; NaN, 0.7; NaN, 0.9], ...
                ["A"; "B"; "B"; "ignored"], ...
                [true; true; true; false]);

            testCase.verifyFalse(result.IsValid);
            testCase.verifyEqual( ...
                result.ErrorMessage, ...
                "MDV experimental data contains NaN values in the " + ...
                "following fragments: B.");

        end

        function acceptsFiniteSelectedMDVValues(testCase)

            validator = openmebius.mfa.MFAInputValidator();

            result = validator.validateMDV( ...
                [0.2, 0.3; NaN, NaN], ...
                ["A"; "unused"], ...
                [true; false]);

            testCase.verifyTrue(result.IsValid);

        end

        function rejectsMismatchedMDVMetadata(testCase)

            validator = openmebius.mfa.MFAInputValidator();

            result = validator.validateMDV( ...
                [0.2; 0.8], "A", [true; true]);

            testCase.verifyFalse(result.IsValid);
            testCase.verifyEqual( ...
                result.ErrorMessage, ...
                "MDV fragment labels and mask must match the " + ...
                "experimental data row count.");

        end

    end

    methods (Static, Access = private)

        function experiments = experiments(growthRate, uptakeValues)

            rowNames = {'E1', 'E2'};
            info = table( ...
                growthRate, ...
                VariableNames = {'mu'}, ...
                RowNames = rowNames);
            uptake = array2table( ...
                uptakeValues, ...
                VariableNames = {'A', 'B'}, ...
                RowNames = rowNames);
            experiments = ...
                helpers.MFAInputValidationExperimentsStub( ...
                info, uptake);

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
