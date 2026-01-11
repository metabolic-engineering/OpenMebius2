dirModel = "../../model";
ModelDir = IO(dirModel);

directory = dispDirList("metabolic model", "model", dirModel, ModelDir.dirList);

clear ModelDir;

Model = ReportResult(fullfile(dirModel, directory ,'results'));
