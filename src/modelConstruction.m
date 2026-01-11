dirModel = "../model";
ModelDir = IO(dirModel);

directory = dispDirList("metabolic model", "model", dirModel, ModelDir.dirList);
clear ModelDir;

Model = EMUModel(fullfile(dirModel, directory));
fmt = @(e) sprintf('%s %s [%s]: %s', ...
    e.DateTimeStr, upper(string(e.Level)), string(e.Caller), string(e.Message));
lh = addlistener(Model, 'generalMsg', @(src, event) fprintf('%s\n', fmt(event)));
