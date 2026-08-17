classdef PathwayLabelServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function setsLabelPosition(testCase)

            model = helpers.PathwayLabelModelStub();
            service = openmebius.application.model.PathwayLabelService();

            result = service.setPosition(model, "R1", [12.5 4.25]);

            testCase.verifyTrue(model.Called);
            testCase.verifyEqual(model.ReactionID, "R1");
            testCase.verifyEqual(model.Position, [12.5 4.25]);
            testCase.verifyFalse(result.IsRemoved);
            testCase.verifyEqual(result.Position, [12.5 4.25]);
            testCase.verifyEqual(result.ModelTable{1, ["x", "y"]}, ...
                [12.5 4.25]);

        end

        function removesLabelPosition(testCase)

            model = helpers.PathwayLabelModelStub();
            service = openmebius.application.model.PathwayLabelService();

            result = service.removePosition(model, "R1");

            testCase.verifyTrue(result.IsRemoved);
            testCase.verifyTrue(all(isnan(model.Position)));
            testCase.verifyThat( ...
                result.Messages, ...
                matlab.unittest.constraints.ContainsSubstring( ...
                "removed"));

        end

        function requiresReactionSelection(testCase)

            model = helpers.PathwayLabelModelStub();
            service = openmebius.application.model.PathwayLabelService();

            testCase.verifyError( ...
                @() service.setPosition(model, "", [1 2]), ...
                "OpenMebius2:PathwayLabel:ReactionRequired");
            testCase.verifyFalse(model.Called);

        end

        function rejectsInvalidCoordinates(testCase)

            model = helpers.PathwayLabelModelStub();
            service = openmebius.application.model.PathwayLabelService();

            testCase.verifyError( ...
                @() service.setPosition(model, "R1", [NaN 2]), ...
                "OpenMebius2:PathwayLabel:InvalidPosition");
            testCase.verifyFalse(model.Called);

        end

    end % methods (Test)

end % classdef
