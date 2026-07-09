classdef ProjectLayout
    % PROJECTLAYOUT
    % Centralizes the conventional OpenMebius2 project file layout.

    properties (Constant)
        ModelDirectoryName = "model"
        ExperimentDirectoryName = "experiments"
        ResultDirectoryName = "results"
        SettingFileName = "setting.json"
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

        end % method resolve

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
