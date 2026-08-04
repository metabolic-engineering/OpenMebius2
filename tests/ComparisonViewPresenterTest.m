classdef ComparisonViewPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function presentsCatalog(testCase)

            service = helpers.ExperimentComparisonServiceStub();
            service.Catalog = openmebius.application.experiment ...
                .ExperimentComparisonCatalog( ...
                    ExperimentNames = ["ExpA", "ExpB"], ...
                    DataNames = ["FragA", "FragB"]);
            experiments = helpers.ExperimentComparisonWorkspaceStub([]);
            presenter = openmebius.presentation.experiment ...
                .ComparisonViewPresenter( ...
                    experiments, Service = service);

            viewModel = presenter.presentCatalog();

            testCase.verifyTrue(viewModel.IsAvailable);
            testCase.verifyEqual( ...
                viewModel.ExperimentItems, ["ExpA", "ExpB"]);
            testCase.verifyEqual( ...
                viewModel.DataItems, ["FragA", "FragB"]);

        end

        function transposesComparisonForExperimentBars(testCase)

            service = helpers.ExperimentComparisonServiceStub();
            comparison = array2table( ...
                [0.8, 0.7; 0.2, 0.3], ...
                VariableNames = ["ExpA", "ExpB"], ...
                RowNames = ["M0", "M1"]);
            service.Selection = openmebius.application.experiment ...
                .ExperimentComparisonSelection( ...
                    ExperimentNames = ["ExpA", "ExpB"], ...
                    DataNames = "Frag", ...
                    Tables = {comparison});
            experiments = helpers.ExperimentComparisonWorkspaceStub([]);
            presenter = openmebius.presentation.experiment ...
                .ComparisonViewPresenter( ...
                    experiments, Service = service);

            viewModel = presenter.presentSelection( ...
                ["ExpA", "ExpB"], "Frag");

            testCase.verifyTrue(viewModel.IsAvailable);
            testCase.verifyEqual( ...
                viewModel.Values{1}, ...
                [0.8, 0.2; 0.7, 0.3], ...
                AbsTol = 1e-12);
            testCase.verifyEqual( ...
                viewModel.StackLabels{1}, ["M0", "M1"]);

        end

        function presentsKnownFailureAsWarning(testCase)

            service = helpers.ExperimentComparisonServiceStub();
            service.Exception = MException( ...
                "OpenMebius2:ExperimentComparison:Unavailable", ...
                "Calculate MDV first.");
            experiments = helpers.ExperimentComparisonWorkspaceStub([]);
            presenter = openmebius.presentation.experiment ...
                .ComparisonViewPresenter( ...
                    experiments, Service = service);

            viewModel = presenter.presentCatalog();

            testCase.verifyFalse(viewModel.IsAvailable);
            testCase.verifyEqual( ...
                viewModel.Notifications{1}.Level, "warning");
            testCase.verifyFalse( ...
                viewModel.Notifications{1}.ShowAlert);

        end

    end

end
