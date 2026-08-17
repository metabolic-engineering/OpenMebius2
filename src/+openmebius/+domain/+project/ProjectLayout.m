classdef ProjectLayout
    % PROJECTLAYOUT
    % Centralizes the conventional OpenMebius2 project file layout.

    properties (Constant)
        ModelDirectoryName = "model"
        ExperimentDirectoryName = "experiments"
        ResultDirectoryName = "results"

        SettingFileName = "setting.om2"
        LegacySettingFileName = "setting.json"
    end

    methods (Static)

        function layout = resolve(rootDirectory)

            rootDirectory = string(rootDirectory);

            import openmebius.domain.project.ProjectLayout

            layout = struct();
            layout.RootDirectory = rootDirectory;

            layout.ModelDirectory = fullfile( ...
                rootDirectory, ...
                ProjectLayout.ModelDirectoryName);

            layout.ExperimentDirectory = fullfile( ...
                rootDirectory, ...
                ProjectLayout.ExperimentDirectoryName);

            layout.ResultDirectory = fullfile( ...
                rootDirectory, ...
                ProjectLayout.ResultDirectoryName);

            layout.SettingFile = fullfile( ...
                rootDirectory, ...
                ProjectLayout.SettingFileName);

            layout.LegacySettingFile = fullfile( ...
                rootDirectory, ...
                ProjectLayout.LegacySettingFileName);

        end % method resolve

        function names = settingFileNames()

            import openmebius.domain.project.ProjectLayout

            names = [
                ProjectLayout.SettingFileName
                ProjectLayout.LegacySettingFileName
                ];

        end % method settingFileNames

        function tf = isSettingFile(filePath)

            [~, name, ext] = fileparts(string(filePath));
            fileName = name + ext;

            tf = any(strcmpi( ...
                fileName, ...
                openmebius.domain.project.ProjectLayout.settingFileNames()));

        end % method isSettingFile

        function names = dataDirectoryNames()

            import openmebius.domain.project.ProjectLayout

            names = [
                ProjectLayout.ModelDirectoryName
                ProjectLayout.ExperimentDirectoryName
                ProjectLayout.ResultDirectoryName
                ];

        end % method dataDirectoryNames

    end % methods (Static)

end % classdef
