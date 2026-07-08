classdef ProjectPaths < openmebius.domain.project.ProjectLayout

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
            layout = openmebius.domain.project.ProjectLayout.resolve( ...
                rootDirectory);

            obj.RootDirectory = layout.RootDirectory;
            obj.ModelDirectory = layout.ModelDirectory;
            obj.ExperimentDirectory = layout.ExperimentDirectory;
            obj.ResultDirectory = layout.ResultDirectory;
            obj.SettingFile = layout.SettingFile;

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
