classdef LabelConfigurationIntegrationTest < matlab.unittest.TestCase

    properties
        TemporaryRoot string
        Model
    end

    methods (TestMethodSetup)

        function loadModelCopy(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"), fullfile(root, "tests"));
            testCase.TemporaryRoot = string(tempname);
            mkdir(testCase.TemporaryRoot);
            directory = fullfile(testCase.TemporaryRoot, "model");
            copyfile(fullfile(root, "tutorial", "ecoli", "model"), directory);
            repository = openmebius.infrastructure.model.ModelRepository();
            testCase.Model = repository.load( ...
                openmebius.domain.model.ModelLocation(directory));

        end

    end

    methods (TestMethodTeardown)

        function removeModelCopy(testCase)

            if ~isempty(testCase.Model) && isvalid(testCase.Model)
                delete(testCase.Model);
            end
            if isfolder(testCase.TemporaryRoot)
                rmdir(testCase.TemporaryRoot, 's');
            end

        end

    end

    methods (Test)

        function renamedCustomLabelsSurviveSaveReloadAndSelectionReload(testCase)

            [labels, ratios] = LabelConfigurationIntegrationTest.configuration();
            model = testCase.Model;
            model.updateLabelConfiguration(labels, ratios);
            testCase.verifyEqual(model.getTableLabelView(), labels);
            testCase.verifyEqual(fieldnames(model.getLabelStructView()), ...
                fieldnames(model.getLabelStruct()));

            % Changing the document again makes loadLabel exercise a real reload.
            savedDefinitions = model.getLabelStruct();
            model.updateStructLabel(struct());
            model.loadLabel();
            testCase.verifyEqual(model.getTableLabelView(), labels);
            testCase.verifyEqual(model.getLabelStruct(), savedDefinitions);

            experimentDirectory = fullfile(testCase.TemporaryRoot, "experiments");
            mkdir(experimentDirectory);
            experiments = openmebius.application.experiment.ExperimentSet( ...
                experimentDirectory, model, AllowEmpty = true);
            experimentCleanup = onCleanup(@() delete(experiments));
            tracer = cell2table({'Custom glucose~1'}, ...
                VariableNames = {'Subs_Glc'}, RowNames = {'E1'});
            service = openmebius.application.experiment.TracerConfigurationService();
            decision = service.prepare(experiments, tracer, [1, 1]);
            context = openmebius.presentation.experiment.TracerConfigContext( ...
                EditorTable = decision.EditorTable, Position = [1, 1]);
            app = TracerConfig_exported(context);
            appCleanup = onCleanup(@() delete(app));
            changed = app.UITable.Data;
            changed.Select(:) = false;
            app.UITable.Data = changed;

            callback = app.ReloadButton.ButtonPushedFcn;
            callback([], []);

            testCase.verifyEqual(app.UITable.Data.Label, "Custom glucose");
            testCase.verifyTrue(app.UITable.Data.Select);
            testCase.verifyEqual(app.UITable.Data.Ratio, 1);

        end

        function batchSubstrateInputsUseCurrentLabelsAfterRenameAndRemoval(testCase)

            model = testCase.Model;
            model.substrateEMUsAll();
            [labels, ratios] = LabelConfigurationIntegrationTest.configuration();
            model.updateLabelConfiguration(labels, ratios);
            tracer = cell2table({'Custom glucose~1', 'Custom carbon~1'}, ...
                VariableNames = {'Subs_Glc', 'Subs_CO2'}, RowNames = {'E1'});
            experiments = helpers.SubstrateEMUExperimentsStub(tracer);
            factory = openmebius.mfa.SubstrateEMUFactory();

            actual = factory.fromExperiment(model, experiments, "E1");

            expected = [model.substrateEMUs({'#0'}, 1, numAtom = 6); ...
                model.substrateEMUs({'#111111'; '#000000'}, ...
                [0.8; 0.2], numAtom = 6)];
            testCase.verifyEqual(actual, expected, AbsTol = 1e-12);
            testCase.verifySize(actual, [64, 7]);
            testCase.verifyEqual(fieldnames(model.getLabelStructEMU()), ...
                fieldnames(model.getLabelStruct()));

            % Rename and reorder after the numerical templates have been built.
            labels = labels([2, 1], :);
            labels.Name{2} = 'Renamed glucose';
            ratios = orderfields(model.getLabelStructView(), [2, 1]);
            model.updateLabelConfiguration(labels, ratios);
            experiments.TracerTable{1, 1} = {'Renamed glucose~1'};
            actual = factory.fromExperiment(model, experiments, "E1");
            testCase.verifyEqual(actual, expected, AbsTol = 1e-12);
            testCase.verifyEqual(numel(fieldnames(model.getLabelStructEMU())), 2);

        end

        function newlyAddedRatioRowsCanBeUsedForBatchInputs(testCase)

            model = testCase.Model;
            action = openmebius.presentation.model.LabelConfigAction( ...
                model.getTableLabelView(), model.getLabelStructView());
            action.addLabel();
            labels = action.LabelTable;
            labels.Name{end} = 'New custom glucose';
            labels.Num{end} = 6;
            action.updateLabelTable(labels);
            action.addRatio(height(labels));
            ratio = action.selectLabel(height(labels));
            ratio.Label{1} = '#111111';
            action.updateRatioTable(height(labels), ratio);
            model.updateLabelConfiguration(action.LabelTable, action.RatioTables);
            tracer = cell2table({'New custom glucose~1'}, ...
                VariableNames = {'Subs_Glc'}, RowNames = {'E1'});
            factory = openmebius.mfa.SubstrateEMUFactory();

            actual = factory.fromExperiment( ...
                model, helpers.SubstrateEMUExperimentsStub(tracer), "E1");

            testCase.verifyEqual(actual, ...
                model.substrateEMUs({'#111111'}, 1, numAtom = 6));

        end

    end

    methods (Static, Access = private)

        function [labels, ratios] = configuration()

            labels = table({'Custom glucose'; 'Custom carbon'}, {6; 1}, ...
                VariableNames = {'Name', 'Num'});
            ratios = struct();
            ratios.NewLabel = table({'#111111'; '#000000'}, [0.8; 0.2], ...
                VariableNames = {'Label', 'Ratio'});
            ratios.NewLabel_1 = table({'#0'}, 1, ...
                VariableNames = {'Label', 'Ratio'});

        end

    end

end
