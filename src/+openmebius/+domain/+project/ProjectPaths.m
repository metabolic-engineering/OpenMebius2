classdef ProjectPaths

    properties (SetAccess = private)
        RootDirectory (1, 1) string
        ModelDirectory (1, 1) string
        ExperimentDirectory (1, 1) string
        ResultDirectory (1, 1) string
        SettingFile (1, 1) string
    end

    methods

        function obj = ProjectPaths(rootDirectory)

            arguments
                rootDirectory (1, 1) string
            end

            rootDirectory = string(rootDirectory);

            obj.RootDirectory = rootDirectory;
            obj.ModelDirectory = fullfile(rootDirectory, "model");
            obj.ExperimentDirectory = fullfile(rootDirectory, "experiments");
            obj.ResultDirectory = fullfile(rootDirectory, "results");
            obj.SettingFile = fullfile(rootDirectory, "setting.json");

        end % constructor

        function assertExists(obj)

            if ~isfolder(obj.RootDirectory)
                error( ...
                    "OpenMebius2:Project:DirectoryNotFound", ...
                    "Project directory does not exist: %s", ...
                    obj.RootDirectory);
            end

            if ~isfile(obj.SettingFile)
                error( ...
                    "OpenMebius2:Project:SettingFileNotFound", ...
                    "setting.json was not found: %s", ...
                    obj.SettingFile);
            end

        end % method assertExists

    end % methods

end % classdef
