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
                .BatchOperationOutcome("finished");

            autoFill = presenter.presentAutoFillOutcome(outcome, batch);
            saved = presenter.presentSaveOutcome(outcome, batch);
            removed = presenter.presentRemoveOutcome(outcome, batch);
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
            testCase.verifyEqual( ...
                reloaded.Notifications{1}.Message, ...
                "Batch table reloaded");

        end

        function presentsBatchOperationFailure(testCase)

            batch = helpers.BatchOperationStub();
            presenter = openmebius.presentation.batch.BatchPresenter();
            outcome = openmebius.application.batch ...
                .BatchOperationOutcome( ...
                    "error", ErrorMessage = "Save failed.");

            viewModel = presenter.presentSaveOutcome(outcome, batch);
            notification = viewModel.Notifications{1};

            testCase.verifyEmpty(viewModel.TableViewModel);
            testCase.verifyEqual(notification.Level, "error");
            testCase.verifyEqual(notification.Title, "Batch table save failed");
            testCase.verifyTrue(notification.ShowAlert);

        end

    end % methods (Test)

end % classdef
