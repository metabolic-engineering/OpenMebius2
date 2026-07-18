classdef ResultPlotPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function presentsPathwayWithoutFluxSelection(testCase)

            presenter = openmebius.presentation.result ...
                .ResultPlotPresenter();
            model = testCase.model();
            result = helpers.ResultPlotWorkspaceStub();
            context = testCase.context();
            context.SelectedMainRows = zeros(0, 1);

            viewModel = presenter.present(model, result, context);

            testCase.verifyEqual( ...
                viewModel.Kind, ...
                openmebius.presentation.result.ResultPlotKind.OverviewFlux);
            testCase.verifyEqual( ...
                viewModel.MainPlot.Pathway.Labels, "1.25");
            testCase.verifyFalse(any( ...
                viewModel.MainPlot.Pathway.Highlight));
            testCase.verifyFalse(isfield(viewModel.MainPlot, "Model"));
            testCase.verifyEmpty(fieldnames(viewModel.SubPlot));
            testCase.verifyFalse(result.Called);

        end

        function presentsSelectedReactionConfidenceInterval(testCase)

            presenter = openmebius.presentation.result ...
                .ResultPlotPresenter();
            model = testCase.model();
            result = helpers.ResultPlotWorkspaceStub();
            result.ConfidenceIntervalData = testCase.ciData();
            context = testCase.context();

            viewModel = presenter.present(model, result, context);

            testCase.verifyTrue(result.Called);
            testCase.verifyEqual(result.BatchID, "batch-1");
            testCase.verifyEqual(result.ReactionID, "R1");
            testCase.verifyTrue( ...
                viewModel.MainPlot.Pathway.Highlight);
            testCase.verifyEqual( ...
                viewModel.SubPlot.Kind, "monte-carlo-ci");
            testCase.verifyEqual( ...
                viewModel.SubPlot.LowerBounds, [0.8 0.9]);
            testCase.verifyEqual( ...
                viewModel.SubPlot.UpperBounds, [1.6 1.5]);
            testCase.verifyEqual(viewModel.SubPlot.BestFit, 1.25);
            testCase.verifyEqual(viewModel.SubPlot.Title, "First reaction");
            testCase.verifyEmpty(viewModel.Notification);

        end

        function clearsPlotsOutsideOverview(testCase)

            presenter = openmebius.presentation.result ...
                .ResultPlotPresenter();
            context = testCase.context();
            context.Mode = "Details";
            result = helpers.ResultPlotWorkspaceStub();

            viewModel = presenter.present( ...
                testCase.model(), result, context);

            testCase.verifyEqual( ...
                viewModel.Kind, ...
                openmebius.presentation.result.ResultPlotKind.None);
            testCase.verifyFalse(result.Called);

        end

        function warnsForUnsupportedConfidenceInterval(testCase)

            presenter = openmebius.presentation.result ...
                .ResultPlotPresenter();
            result = helpers.ResultPlotWorkspaceStub();
            data = testCase.ciData();
            data.CI.algorithm = "Grid Search";
            result.ConfidenceIntervalData = data;

            viewModel = presenter.present( ...
                testCase.model(), result, testCase.context());

            testCase.verifyEmpty(fieldnames(viewModel.SubPlot));
            testCase.verifyEqual(viewModel.Notification.Level, "warning");
            testCase.verifyThat( ...
                viewModel.Notification.Message, ...
                matlab.unittest.constraints.ContainsSubstring( ...
                    "Unsupported confidence interval"));

        end

        function rejectsInvalidResultSelection(testCase)

            presenter = openmebius.presentation.result ...
                .ResultPlotPresenter();
            context = testCase.context();
            context.SelectedSubRows = 3;

            viewModel = presenter.present( ...
                testCase.model(), ...
                helpers.ResultPlotWorkspaceStub(), ...
                context);

            testCase.verifyEqual( ...
                viewModel.Kind, ...
                openmebius.presentation.result.ResultPlotKind.None);

        end

    end % methods (Test)

    methods (Static, Access = private)

        function value = model()

            value = helpers.ResultPlotModelStub();
            value.PathwayData = openmebius.application.model ...
                .ModelPathwayData( ...
                    Image = ones(2), ...
                    ReactionIDs = "R1", ...
                    X = 1, ...
                    Y = 2);

        end

        function value = context()

            value = struct();
            value.Mode = "Overview";
            value.SelectedMainRows = 1;
            value.SelectedSubRows = 1;
            value.MainTableData = table( ...
                ["First reaction"; ""], ...
                [1.25; 0.5], ...
                'VariableNames', {'Reaction', 'Flux'}, ...
                'RowNames', {'R1', 'biomass'});
            value.SubTableData = table( ...
                "batch-1", "First", ...
                'VariableNames', {'ID', 'Name'});
            value.MainTableRowNames = ["R1"; "biomass"];
            value.SubTableRowNames = strings(0, 1);

        end

        function value = ciData()

            value = struct();
            value.CI.algorithm = "Monte Carlo";
            value.CI.fluxLB = [0.8 0.9];
            value.CI.fluxUB = [1.6 1.5];
            value.fluxFwd = 1.25;
            value.model.modelID = "R1";
            value.model.modelReaction = "First reaction";

        end

    end % methods (Static, Access = private)

end % classdef
