classdef RunConfigPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

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

        function presentsCompleteEditorState(testCase)

            batch = helpers.RunConfigBatchStub();
            session = openmebius.application.batch ...
                .BatchConfigurationSession(batch, [], "batch-a");
            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();

            editor = presenter.presentEditor(session);

            testCase.verifyClass( ...
                editor, ...
                'openmebius.presentation.batch.RunConfigEditorViewModel');
            testCase.verifyEqual(editor.Config.Iteration, 30);
            testCase.verifyEqual(height(editor.MSFragmentTable.Data), 2);
            testCase.verifyEqual(width(editor.MSFragmentTable.Data), 1);
            testCase.verifyFalse(editor.ControlState.EffluxEnabled);
            testCase.verifyEmpty(editor.Notifications);

        end

        function reportsUnavailableINSTMFAForMultipleBatches(testCase)

            batch = helpers.RunConfigBatchStub();
            batch.Config.isINSTMFA = true;
            session = openmebius.application.batch ...
                .BatchConfigurationSession( ...
                    batch, [], ["batch-a"; "batch-b"]);
            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();

            editor = presenter.presentEditor(session);

            testCase.verifyFalse(editor.Config.IsINSTMFA);
            testCase.verifyFalse( ...
                editor.INSTMFATables.IsAvailable);
            testCase.verifyNumElements(editor.Notifications, 1);
            testCase.verifyEqual( ...
                editor.Notifications{1}.Level, "error");
            testCase.verifyTrue(editor.Notifications{1}.ShowAlert);

        end

        function createsTypedApplyRequest(testCase)

            batch = helpers.RunConfigBatchStub();
            session = openmebius.application.batch ...
                .BatchConfigurationSession(batch, [], "batch-a");
            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();
            editor = presenter.presentEditor(session);
            configViewModel = editor.Config;
            configViewModel.Iteration = 81;

            request = presenter.createApplyRequest( ...
                session, ...
                configViewModel, ...
                editor.MSFragmentTable.Data, ...
                editor.MSFragmentTable.Metadata, ...
                table(), ...
                false);

            testCase.verifyClass( ...
                request, ...
                ['openmebius.application.batch.' ...
                 'BatchConfigurationApplyRequest']);
            testCase.verifyEqual(request.Config.iteration, 81);
            testCase.verifyFalse(request.ApplySuggestion);

        end

        function presentsApplyErrorAsNotification(testCase)

            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();
            exception = MException( ...
                "OpenMebius2:Test:ApplyFailed", ...
                "Apply failed.");
            outcome = openmebius.application.batch ...
                .BatchConfigurationApplyOutcome( ...
                    "error", ...
                    ErrorMessage = "Apply failed.", ...
                    Exception = exception);

            viewModel = presenter.presentApplyOutcome(outcome);

            testCase.verifyFalse(viewModel.IsSuccessful);
            testCase.verifyNumElements(viewModel.Notifications, 1);
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Level, "error");
            testCase.verifyTrue(viewModel.Notifications{1}.ShowAlert);

        end

        function presentsExperimentSelectionEditorRequest(testCase)

            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();
            request = openmebius.application.batch ...
                .BatchExperimentSelectionEditorRequest( ...
                    ["exp-a"; "exp-b"], ...
                    "inst-mfa", ...
                    "batch-a");
            outcome = openmebius.application.batch ...
                .BatchConfigurationChildOutcome( ...
                    "finished", Result = request);

            viewModel = presenter ...
                .presentExperimentSelectionEditorOutcome(outcome);

            testCase.verifyTrue(viewModel.IsAvailable);
            testCase.verifyEqual( ...
                viewModel.ExperimentNames, ["exp-a"; "exp-b"]);
            testCase.verifyEqual(viewModel.Mode, "inst-mfa");
            testCase.verifyEqual(viewModel.BatchId, "batch-a");
            testCase.verifyEmpty(viewModel.Notifications);

        end

        function presentsExperimentSelectionEditorFailure(testCase)

            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();
            exception = MException( ...
                "OpenMebius2:Test:ChildEditorFailed", ...
                "Child editor failed.");
            outcome = openmebius.application.batch ...
                .BatchConfigurationChildOutcome( ...
                    "error", ...
                    ErrorMessage = "Child editor failed.", ...
                    Exception = exception);

            viewModel = presenter ...
                .presentExperimentSelectionEditorOutcome(outcome);

            testCase.verifyFalse(viewModel.IsAvailable);
            testCase.verifyNumElements(viewModel.Notifications, 1);
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Level, "error");
            testCase.verifyTrue(viewModel.Notifications{1}.ShowAlert);

        end

    end % methods (Test)

end % classdef
