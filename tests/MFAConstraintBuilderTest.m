classdef MFAConstraintBuilderTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAConstraintBuilderTest.sourcePath());

        end

    end

    methods (Test)

        function buildsBiomassAndEffluxRightHandSide(testCase)

            builder = openmebius.mfa.MFAConstraintBuilder();
            model = helpers.MFAConstraintModelStub();

            result = builder.buildRightHandSide( ...
                model, 0.2, ["A"; "B"], [10; 3]);

            testCase.verifyEqual(result, [0.2; 10; 3; 0]);

        end

        function leavesUnmeasuredEffluxAtZero(testCase)

            builder = openmebius.mfa.MFAConstraintBuilder();

            result = builder.buildRightHandSide( ...
                helpers.MFAConstraintModelStub(), ...
                0.1, ...
                "A", ...
                8);

            testCase.verifyEqual(result, [0.1; 8; 0; 0]);

        end

        function identifiesOnlySelectedFreeEffluxRows(testCase)

            builder = openmebius.mfa.MFAConstraintBuilder();
            model = helpers.MFAConstraintModelStub();

            result = builder.effluxFreeConstraintRowMask( ...
                model, ...
                model.getSBefore(), ...
                ["A"; "B"], ...
                [false; true]);

            testCase.verifyEqual(result, [false; false; true]);

        end

        function returnsEmptyMaskWhenNoEffluxIsFree(testCase)

            builder = openmebius.mfa.MFAConstraintBuilder();
            model = helpers.MFAConstraintModelStub();

            result = builder.effluxFreeConstraintRowMask( ...
                model, model.getSBefore(), [], []);

            testCase.verifyEqual(result, false(3, 1));

        end

        function identifiesGrowthRateAsFreeConstraint(testCase)

            builder = openmebius.mfa.MFAConstraintBuilder();
            model = helpers.MFAConstraintModelStub();

            result = builder.effluxFreeConstraintRowMask( ...
                model, model.getSBefore(), [], [], ...
                FreeGrowthRate = true);

            testCase.verifyEqual(result, [true; false; false]);

        end

        function rejectsMismatchedEffluxInputs(testCase)

            builder = openmebius.mfa.MFAConstraintBuilder();

            testCase.verifyError( ...
                @() builder.buildRightHandSide( ...
                helpers.MFAConstraintModelStub(), ...
                0.2, ...
                ["A"; "B"], ...
                10), ...
                "OpenMebius2:MFAConstraintBuilder:" + ...
            "EffluxDimensionMismatch");

        end

        function rejectsMissingConstraintTypes(testCase)

            builder = openmebius.mfa.MFAConstraintBuilder();
            model = helpers.MFAConstraintModelStub();
            model.ConstraintTypes = ["dependent"; "efflux"];

            testCase.verifyError( ...
                @() builder.buildRightHandSide( ...
                model, 0.2, ["A"; "B"], [10; 3]), ...
                "OpenMebius2:MFAConstraintMetadata:" + ...
            "TypeDimensionMismatch");

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
