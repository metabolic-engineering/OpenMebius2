dirExp = "../../experiments";
dirModel = "../../model/sample";

Experiment = openmebius.application.experiment.ExperimentWorkspace( ...
    fullfile(dirExp), ...
    fullfile(dirModel));
MFA = MFA(Experiment.objModel, Experiment);
