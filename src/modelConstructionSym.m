dirModel = "../../model";
ModelDir = IO(dirModel);

directory = dispDirList("metabolic model", "model", dirModel, ModelDir.dirList);

clear ModelDir;

Model = EMUModelSym(fullfile(dirModel, directory));
