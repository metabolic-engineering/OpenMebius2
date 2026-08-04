classdef MSViewPresenterTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename('fullpath')));
            addpath(fullfile(root, 'src'));
            addpath(fullfile(root, 'tests'));

        end

    end

    methods (Test)

        function presentsExperimentIdentityAndCalculationState(testCase)

            experiments = helpers.MSViewExperimentsStub();
            presenter = openmebius.presentation.experiment ...
                .MSViewPresenter(experiments);

            testCase.verifyEqual( ...
                presenter.experimentNames(), ...
                ["Experiment A", "Experiment B"]);
            testCase.verifyEqual( ...
                presenter.experimentNameAt(2), "Experiment B");
            testCase.verifyFalse(presenter.hasCalculatedMDV());

            experiments.HasCalculatedMDV = true;
            testCase.verifyTrue(presenter.hasCalculatedMDV());

        end

        function presentsIndependentMSDataModes(testCase)

            experiments = helpers.MSViewExperimentsStub();
            presenter = openmebius.presentation.experiment ...
                .MSViewPresenter(experiments);
            raw = presenter.presentTable( ...
                "Experiment A", "MS raw data");
            normalized = presenter.presentTable( ...
                "Experiment A", "MS normarized data");
            mdv = presenter.presentTable( ...
                "Experiment A", "MDV (Mass distribution vectors)");

            testCase.verifyEqual(raw.Data, experiments.Raw);
            testCase.verifyEqual(normalized.Data, experiments.Normalized);
            testCase.verifyEqual(mdv.Data, experiments.MDV);
            testCase.verifyTrue(raw.ExperimentSelectionEnabled);
            testCase.verifyFalse(raw.UseHeatmap);
            testCase.verifyEmpty(raw.ErrorColumns);

        end

        function presentsBiomassColumnErrors(testCase)

            experiments = helpers.MSViewExperimentsStub();
            presenter = openmebius.presentation.experiment ...
                .MSViewPresenter(experiments);

            viewModel = presenter.presentTable( ...
                "Experiment A", "Biomass corrected MDV");

            testCase.verifyEqual(viewModel.Data, experiments.Biomass);
            testCase.verifyEqual( ...
                viewModel.ErrorColumns, [false, true]);
            testCase.verifyEmpty(viewModel.ErrorMask);

        end

        function presentsEnrichmentHeatmapAndRowErrors(testCase)

            experiments = helpers.MSViewExperimentsStub();
            presenter = openmebius.presentation.experiment ...
                .MSViewPresenter(experiments);

            viewModel = presenter.presentTable( ...
                "Experiment A", "Enrichment");

            testCase.verifyEqual(viewModel.Data, experiments.Enrichment);
            testCase.verifyFalse(viewModel.ExperimentSelectionEnabled);
            testCase.verifyTrue(viewModel.UseHeatmap);
            testCase.verifyEqual( ...
                viewModel.ErrorMask, [false, true; true, false]);

        end

        function rejectsUnknownTableType(testCase)

            presenter = openmebius.presentation.experiment ...
                .MSViewPresenter(helpers.MSViewExperimentsStub());

            testCase.verifyError( ...
                @() presenter.presentTable("Experiment A", "unknown"), ...
                "OpenMebius2:MSViewPresenter:UnknownTableType");

        end

    end

end
