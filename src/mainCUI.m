dirExp = "../../experiments";
dirModel = "../../model/sample";

Experiment = IOExps(fullfile(dirExp), fullfile(dirModel));
MFA = MFA(Experiment.objModel, Experiment);
