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
            testCase.verifyTrue(viewModel.GridAutomaticInterval);
            testCase.verifyTrue(viewModel.GridParallelExecution);
            testCase.verifyFalse(viewModel.PerturbateEfflux);
            testCase.verifyFalse(viewModel.IsINSTMFA);

        end

        function createsLaunchRequestFromTableSelection(testCase)

            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();
            tableData = table( ...
                ["batch-a"; "batch-b"], ...
                VariableNames = "ID");

            request = presenter.createLaunchRequest( ...
                tableData, [2, 1; 1, 1]);

            testCase.verifyClass( ...
                request, ...
                ['openmebius.application.batch.' ...
             'BatchConfigurationLaunchRequest']);
            testCase.verifyEqual( ...
                request.BatchIds, ["batch-b"; "batch-a"]);

        end

        function presentsLaunchOutcome(testCase)

            batch = helpers.RunConfigBatchStub();
            session = openmebius.application.batch ...
                .BatchConfigurationSession(batch, [], "batch-a");
            outcome = openmebius.application.batch ...
                .BatchConfigurationLaunchOutcome( ...
                true, Session = session);
            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();

            viewModel = presenter.presentLaunchOutcome(outcome);

            testCase.verifyTrue(viewModel.IsAvailable);
            testCase.verifyEqual(viewModel.Session, session);
            testCase.verifyClass( ...
                viewModel.Editor, ...
            'openmebius.presentation.batch.RunConfigEditorViewModel');

        end

        function presentsLaunchFailureAsNotification(testCase)

            exception = MException( ...
                "OpenMebius2:Test:LaunchFailed", ...
            "Launch failed.");
            outcome = openmebius.application.batch ...
                .BatchConfigurationLaunchOutcome( ...
                false, ...
                ErrorMessage = "Launch failed.", ...
                Exception = exception);
            presenter = openmebius.presentation.batch ...
                .RunConfigPresenter();

            viewModel = presenter.presentLaunchOutcome(outcome);

            testCase.verifyFalse(viewModel.IsAvailable);
            testCase.verifyNumElements(viewModel.Notifications, 1);
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Title, ...
            "Batch configuration error");
            testCase.verifyTrue(viewModel.Notifications{1}.ShowAlert);

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
            testCase.verifyFalse(state.GridExecutionModeEnabled);
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
            testCase.verifyTrue(automatic.GridExecutionModeEnabled);
            testCase.verifyTrue(automatic.GridPointsEnabled);
            testCase.verifyFalse(automatic.GridDeltaEnabled);
            testCase.verifyFalse(manual.GridPointsEnabled);
            testCase.verifyTrue(manual.GridDeltaEnabled);
            testCase.verifyTrue(automatic.GridReactionVisible);

            viewModel.CalculateCI = false;
            disabled = presenter.presentControlState(viewModel);
            testCase.verifyFalse(disabled.GridReactionVisible);
            testCase.verifyFalse(disabled.GridExecutionModeEnabled);

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
            testCase.verifyEqual( ...
                editor.GridReactionTable.Data.Properties.VariableNames, ...
                {'Select', 'ID', 'Reaction'});
            testCase.verifyTrue( ...
                all(editor.GridReactionTable.Data.Select));
            testCase.verifyEqual( ...
                editor.GridReactionTable.ColumnEditable, ...
                [true, false, false]);
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
                false, ...
                ErrorMessage = "Apply failed.", ...
                Exception = exception);

            viewModel = presenter.presentApplyOutcome(outcome);

            testCase.verifyFalse(viewModel.IsSuccessful);
            testCase.verifyNumElements(viewModel.Notifications, 1);
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Level, "error");
            testCase.verifyTrue(viewModel.Notifications{1}.ShowAlert);

        end

    end % methods (Test)

end % classdef
