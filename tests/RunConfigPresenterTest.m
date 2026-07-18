classdef RunConfigPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function presentsDefaultConfiguration(testCase)

            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();

            viewModel = presenter.presentDefaults();

            testCase.verifyClass( ...
                viewModel, ...
                'openmebius.presentation.batch.RunConfigViewModel');
            testCase.verifyEqual(viewModel.Iteration, 30);
            testCase.verifyEqual(viewModel.Algorithm, "SQP");
            testCase.verifyFalse(viewModel.CalculateCI);
            testCase.verifyFalse(viewModel.PerturbateEfflux);
            testCase.verifyFalse(viewModel.IsINSTMFA);

        end

        function presentsMonteCarloControlState(testCase)

            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();
            viewModel = presenter.presentDefaults();
            viewModel.CalculateCI = true;
            viewModel.CIAlgorithm = "Monte Carlo";
            viewModel.PerturbateEfflux = true;
            viewModel.SuggestNextFlux = true;

            state = presenter.presentControlState(viewModel);

            testCase.verifyTrue(state.CIAlgorithmEnabled);
            testCase.verifyTrue(state.MonteCarloEnabled);
            testCase.verifyFalse(state.GridEnabled);
            testCase.verifyTrue(state.EffluxEnabled);
            testCase.verifyTrue(state.SuggestionEnabled);

        end

        function presentsGridIntervalControlState(testCase)

            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();
            viewModel = presenter.presentDefaults();
            viewModel.CalculateCI = true;
            viewModel.CIAlgorithm = "Grid search";
            viewModel.GridAutomaticInterval = true;

            automatic = presenter.presentControlState(viewModel);
            viewModel.GridAutomaticInterval = false;
            manual = presenter.presentControlState(viewModel);

            testCase.verifyTrue(automatic.GridEnabled);
            testCase.verifyTrue(automatic.GridPointsEnabled);
            testCase.verifyFalse(automatic.GridDeltaEnabled);
            testCase.verifyFalse(manual.GridPointsEnabled);
            testCase.verifyTrue(manual.GridDeltaEnabled);

        end

        function appliesViewModelToCurrentConfig(testCase)

            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();
            current = openmebius.domain.batch.BatchConfig.defaultConfig();
            viewModel = presenter.presentConfig(current);
            viewModel.Iteration = 64;
            viewModel.Algorithm = "IPMs";

            actual = presenter.applyViewModel(viewModel, current);

            testCase.verifyEqual(actual.iteration, 64);
            testCase.verifyEqual(actual.algorithm, 'interior-point');
            openmebius.domain.batch.BatchConfig.validate(actual);

        end

    end % methods (Test)

end % classdef
