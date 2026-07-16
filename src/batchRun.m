dirExp = "../tutorial/ecoli/experiments";
dirModel = "../tutorial/ecoli/model";
dirResult = "../tutorial/ecoli/results";

exp = openmebius.application.experiment.ExperimentWorkspace( ...
    fullfile(dirExp), ...
    fullfile(dirModel));

batchInstance = Batch(exp);
batchInstance.loadBatchFile(dirExp);
batchInstance.runBatch(dirResult);
