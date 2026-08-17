classdef MFAConstraintMetadataTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(MFAConstraintMetadataTest.sourcePath());

        end

    end

    methods (Test)

        function buildsFromExplicitConstraintTypes(testCase)

            model = helpers.MFAConstraintModelStub();

            metadata = openmebius.mfa.MFAConstraintMetadata ...
                .fromModel(model, model.getSBefore());

            testCase.verifyEqual( ...
                metadata.ReactionIDs, ...
                ["biomass"; "EX_A"; "EX_B"]);
            testCase.verifyEqual( ...
                metadata.ReactionTypes, ...
                ["dependent"; "efflux"; "efflux"]);
            testCase.verifyEqual( ...
                metadata.reactionIDsOfType("efflux"), ...
                ["EX_A"; "EX_B"]);

        end

        function doesNotUseFullSystemTypes(testCase)

            model = helpers.MFAConstraintModelStub();
            model.SystemTypes = [ ...
                model.ConstraintTypes; ...
                "independent"; ...
                "independent"];

            metadata = openmebius.mfa.MFAConstraintMetadata ...
                .fromModel(model, model.getSBefore());

            testCase.verifyEqual( ...
                numel(metadata.ReactionTypes), ...
                height(model.getSBefore()));

        end

        function rejectsMismatchedTypes(testCase)

            model = helpers.MFAConstraintModelStub();
            model.ConstraintTypes = ["dependent"; "efflux"];

            testCase.verifyError( ...
                @() openmebius.mfa.MFAConstraintMetadata.fromModel( ...
                model, model.getSBefore()), ...
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
