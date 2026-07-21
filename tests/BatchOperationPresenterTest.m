classdef BatchOperationPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function presentsSuccessfulBatchOperations(testCase)

            batch = helpers.BatchOperationStub();
            presenter = openmebius.presentation.batch.BatchPresenter();
            outcome = openmebius.application.batch ...
                .BatchOperationOutcome(true);

            autoFill = presenter.presentAutoFillOutcome(outcome, batch);
            saved = presenter.presentSaveOutcome(outcome, batch);
            removed = presenter.presentRemoveOutcome(outcome, batch);
            selection = presenter.presentExperimentSelectionOutcome( ...
                outcome, batch);
            reloaded = presenter.presentReloaded(batch);

            testCase.verifyEqual(autoFill.TableViewModel.Data, batch.Data);
            testCase.verifyThat( ...
                autoFill.Notifications{1}.Message, ...
                matlab.unittest.constraints.ContainsSubstring( ...
                    "automatically filled"));
            testCase.verifyThat( ...
                saved.Notifications{1}.Message, ...
                matlab.unittest.constraints.ContainsSubstring("saved"));
            testCase.verifyThat( ...
                removed.Notifications{1}.Message, ...
                matlab.unittest.constraints.ContainsSubstring("removed"));
            testCase.verifyThat( ...
                selection.Notifications{1}.Message, ...
                matlab.unittest.constraints.ContainsSubstring("updated"));
            testCase.verifyEqual( ...
                reloaded.Notifications{1}.Message, ...
                "Batch table reloaded");

        end

        function abbreviatesDisplayedIdAndPreservesRawId(testCase)

            batch = helpers.BatchOperationStub();
            batch.Data.ID = "bat_dd0eff6798474f24b58b6657e5dd0354";
            presenter = openmebius.presentation.batch.BatchPresenter();

            viewModel = presenter.presentTable(batch);

            testCase.verifyEqual(viewModel.Data.ID, "bat_dd0eff");
            testCase.verifyEqual( ...
                viewModel.RawData.ID, ...
                "bat_dd0eff6798474f24b58b6657e5dd0354");
            testCase.verifyEqual( ...
                batch.RequestedStatusIds, ...
                "bat_dd0eff6798474f24b58b6657e5dd0354");

        end

        function presentsBatchOperationFailure(testCase)

            batch = helpers.BatchOperationStub();
            presenter = openmebius.presentation.batch.BatchPresenter();
            outcome = openmebius.application.batch ...
                .BatchOperationOutcome( ...
                    false, ErrorMessage = "Save failed.");

            viewModel = presenter.presentSaveOutcome(outcome, batch);
            notification = viewModel.Notifications{1};

            testCase.verifyEmpty(viewModel.TableViewModel);
            testCase.verifyEqual(notification.Level, "error");
            testCase.verifyEqual(notification.Title, "Batch table save failed");
            testCase.verifyTrue(notification.ShowAlert);

        end

        function presentsFinishedBatchRemovalAsAlert(testCase)

            batch = helpers.BatchOperationStub();
            presenter = openmebius.presentation.batch.BatchPresenter();
            outcome = openmebius.application.batch ...
                .BatchOperationOutcome( ...
                false, ...
                ErrorMessage = ...
                    "Batch ID bat_dd0eff is finished. Cannot remove.");

            viewModel = presenter.presentRemoveOutcome(outcome, batch);
            notification = viewModel.Notifications{1};

            testCase.verifyEqual(notification.Level, "error");
            testCase.verifyEqual(notification.Title, "Batch removal failed");
            testCase.verifyTrue(notification.ShowAlert);
            testCase.verifyThat( ...
                notification.Message, ...
                matlab.unittest.constraints.ContainsSubstring( ...
                    "bat_dd0eff"));

        end

    end % methods (Test)

end % classdef
