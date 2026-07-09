classdef ProjectPaths < openmebius.domain.project.ProjectLayout

    properties (SetAccess = private)
        RootDirectory (1, 1) string
        ModelDirectory (1, 1) string
        ExperimentDirectory (1, 1) string
        ResultDirectory (1, 1) string
        SettingFile (1, 1) string
        LegacySettingFile (1, 1) string
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
            obj.LegacySettingFile = layout.LegacySettingFile;

        end % constructor

        function assertExists(obj)

            if ~isfolder(obj.RootDirectory)
                error( ...
                    "OpenMebius2:Project:DirectoryNotFound", ...
                    "Project directory does not exist: %s", ...
                    obj.RootDirectory);
            end

            if ~isfile(obj.SettingFile) && ~isfile(obj.LegacySettingFile)
                error( ...
                    "OpenMebius2:Project:SettingFileNotFound", ...
                    "Neither setting.om2 nor setting.json was found in: %s", ...
                    obj.RootDirectory);
            end

        end % method assertExists

        function filePath = activeSettingFile(obj)

            if isfile(obj.SettingFile)
                filePath = obj.SettingFile;
                return
            end

            if isfile(obj.LegacySettingFile)
                filePath = obj.LegacySettingFile;
                return
            end

            filePath = obj.SettingFile;

        end % method activeSettingFile

        function filePaths = settingFileCandidates(obj)

            filePaths = [
                         obj.SettingFile
                         obj.LegacySettingFile
                         ];

        end % method settingFileCandidates

        function location = modelLocation(obj)

            location = ...
                openmebius.domain.model.ModelLocation.fromDirectory( ...
                obj.ModelDirectory);

        end % method modelLocation

        function location = experimentLocation(obj)

            location = ...
                openmebius.domain.experiment.ExperimentLocation.fromDirectory( ...
                obj.ExperimentDirectory);

        end % method experimentLocation

        function location = resultLocation(obj)

            location = ...
                openmebius.domain.result.ResultLocation.fromDirectory( ...
                obj.ResultDirectory);

        end % method resultLocation

    end % methods

end % classdef
