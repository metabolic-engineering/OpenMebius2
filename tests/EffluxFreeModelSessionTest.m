classdef EffluxFreeModelSessionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename('fullpath')));
            addpath(fullfile(root, 'src'));
            addpath(fullfile(root, 'tests'));

        end

    end

    methods (Test)

        function restoresIndependentFlagsWithoutLegacyBuildMethod(testCase)

            model = EffluxFreeModelSessionTest.model();
            observer = helpers.AnalysisMessageObserverStub();
            session = openmebius.application.analysis ...
                .EffluxFreeModelSession( ...
                model, ...
                ["A"; "B"], ...
                MessageReporter = ...
                @(level, message) ...
                observer.report(level, message));

            testCase.verifyTrue(session.IsActive);
            testCase.verifyEqual(model.Independent, [true; true]);

            session.restore();
            session.restore();

            testCase.verifyFalse(session.IsActive);
            testCase.verifyEqual(model.Independent, [false; true]);
            testCase.verifyEqual(model.SetCount, 2);
            testCase.verifyEmpty(observer.Messages);

        end

        function destructorIgnoresDeletedModelAndReporter(testCase)

            model = EffluxFreeModelSessionTest.model();
            observer = helpers.AnalysisMessageObserverStub();
            session = openmebius.application.analysis ...
                .EffluxFreeModelSession( ...
                model, ...
                "A", ...
                MessageReporter = ...
                @(level, message) ...
                observer.report(level, message));
            delete(model);
            delete(observer);

            testCase.verifyWarningFree(@() delete(session));

        end

    end

    methods (Static, Access = private)

        function model = model()

            model = helpers.EffluxFreeModelStub( ...
                ["A"; "B"], ...
                ["EX_A"; "EX_B"], ...
                [false; true]);

        end

    end

end
