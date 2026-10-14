classdef BatchInheritanceIntegrationTest < matlab.unittest.TestCase
    methods (TestMethodSetup)
        function setup(~)
            addpath(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'src'));
        end
    end
    methods (Test)
        function inheritedEditorLocksInitialFitAndAllowsGridChanges(testCase)
            batch = helpers.RunConfigBatchStub();
            batch.Config.inheritedFrom = 'bat_original';
            batch.Config.isCalcCI = true;
            batch.Config.CIConf.algorithm = 'Grid search';
            session = openmebius.application.batch.BatchConfigurationSession(batch, [], 'batch-a');
            presenter = openmebius.presentation.batch.RunConfigPresenter();
            context = openmebius.presentation.batch.RunConfigContext( ...
                Session = session, Presenter = presenter, Editor = presenter.presentEditor(session), ...
                ConfigurationController = openmebius.application.batch.BatchConfigurationController(), ...
                ExperimentEditController = openmebius.application.experiment.ExperimentEditController(), ...
                ExperimentPresenter = openmebius.presentation.experiment.ExperimentPresenter(), ...
                ExperimentSelectionController = openmebius.application.batch.BatchExperimentSelectionEditorController(), ...
                ExperimentSelectionPresenter = openmebius.presentation.batch.BatchExperimentSelectionEditorPresenter());
            app = RunConfig(context);
            cleanup = onCleanup(@() delete(app));
            testCase.verifyEqual(string(app.IterationSpinner.Enable), "off");
            testCase.verifyEqual(string(app.MSTable.Enable), "off");
            testCase.verifyEqual(string(app.MaxIterationsEditField.Enable), "off");
            testCase.verifyEqual(string(app.PerturbateEffluxCheckBox.Enable), "off");
            testCase.verifyEqual(string(app.CalcCICheckBox.Enable), "on");
            testCase.verifyEqual(string(app.IterationtimesforgridsearchEditField.Enable), "on");
            testCase.verifyEqual(string(app.GridReactionUITable.Enable), "on");
            control = findall(app.BatchconfigUIFigure, 'Tag', 'GridParallelIterations');
            testCase.verifyNumElements(control, 1);
            testCase.verifyFalse(control.Value);
            testCase.verifyEqual(control.Layout.Row, app.CheckBox.Layout.Row + 1);
            testCase.verifyEqual(string(control.Enable), "on");
            app.CheckBox.Value = false;
            callback = app.CheckBox.ValueChangedFcn;
            callback([], []);
            testCase.verifyEqual(string(control.Enable), "off");
            testCase.verifyEqual(string(app.IterationSpinner.Enable), "off");
        end
    end
end
