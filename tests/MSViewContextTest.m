classdef MSViewContextTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function storesPresenterAndInitialState(testCase)

            presenter = openmebius.presentation.experiment ...
                .MSViewPresenter(helpers.MSViewExperimentsStub());

            context = openmebius.presentation.experiment ...
                .MSViewContext( ...
                    Presenter = presenter, ...
                    InitialExperimentIndex = 2, ...
                    IsDarkTheme = true);

            testCase.verifyEqual(context.Presenter, presenter);
            testCase.verifyEqual(context.InitialExperimentIndex, 2);
            testCase.verifyTrue(context.IsDarkTheme);

        end

        function rejectsInvalidInitialIndex(testCase)

            presenter = openmebius.presentation.experiment ...
                .MSViewPresenter(helpers.MSViewExperimentsStub());

            testCase.verifyError( ...
                @() openmebius.presentation.experiment ...
                    .MSViewContext( ...
                        Presenter = presenter, ...
                        InitialExperimentIndex = 0), ...
                "MATLAB:validators:mustBePositive");

        end

    end % methods (Test)

end % classdef
