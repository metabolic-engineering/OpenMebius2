classdef CreateProjectUseCase < handle

    properties (Access = private)
        Repository openmebius.infrastructure.project.FileProjectRepository
    end

    methods

        function obj = CreateProjectUseCase(repository)

            arguments
                repository openmebius.infrastructure.project.FileProjectRepository
            end

            obj.Repository = repository;

        end

        function result = execute(obj, options)

            arguments
                obj
                options.ParentDirectory (1, 1) string
                options.ProjectDirectoryName (1, 1) string
                options.TemplateModelDirectory (1, 1) string
                options.Metadata openmebius.domain.project.ProjectMetadata
            end

            parentDirectory = strtrim(options.ParentDirectory);
            projectDirectoryName = strtrim(options.ProjectDirectoryName);
            templateModelDirectory = strtrim(options.TemplateModelDirectory);

            openmebius.application.project.CreateProjectUseCase ...
                .validateInputs( ...
                parentDirectory, ...
                projectDirectoryName, ...
                templateModelDirectory);

            projectDirectory = fullfile(parentDirectory, projectDirectoryName);

            if isfolder(projectDirectory)
                error( ...
                    "OpenMebius2:ProjectCreate:DirectoryAlreadyExists", ...
                    "Project directory already exists: %s", ...
                    projectDirectory);
            end

            try
                mkdir(projectDirectory);

                paths = openmebius.domain.project.ProjectPaths( ...
                    projectDirectory);
                session = openmebius.domain.project.ProjectSession( ...
                    options.Metadata, ...
                    paths);

                obj.Repository.saveProject(session);
                openmebius.infrastructure.project.FileProjectRepository ...
                    .ensureLayout(paths);

                [ok, msg] = copyfile( ...
                    templateModelDirectory, ...
                    paths.ModelDirectory, ...
                    "f");

                if ~ok
                    error( ...
                        "OpenMebius2:ProjectCreate:TemplateCopyFailed", ...
                        "Failed to copy template model: %s", string(msg));
                end
            catch ME
                openmebius.application.project.CreateProjectUseCase ...
                    .cleanupIncompleteProject(projectDirectory);
                rethrow(ME)
            end

            messages = [
                        "New project directory created: " + projectDirectory
                        "Project setting saved to " + paths.SettingFile + ...
                        " and " + paths.LegacySettingFile
                        "Template model copied to " + paths.ModelDirectory
                        ];

            result = openmebius.application.project.ProjectCreateResult( ...
                Session = session, ...
                Messages = messages);

        end

    end

    methods (Static, Access = private)

        function validateInputs( ...
                parentDirectory, ...
                projectDirectoryName, ...
                templateModelDirectory)

            if parentDirectory == ""
                error( ...
                    "OpenMebius2:ProjectCreate:EmptyParentDirectory", ...
                    "Project parent directory is empty.");
            end

            if ~isfolder(parentDirectory)
                error( ...
                    "OpenMebius2:ProjectCreate:ParentDirectoryNotFound", ...
                    "Project parent directory does not exist: %s", ...
                    parentDirectory);
            end

            if projectDirectoryName == ""
                error( ...
                    "OpenMebius2:ProjectCreate:EmptyProjectDirectoryName", ...
                    "Project directory name cannot be empty.");
            end

            [projectParent, projectName, projectExt] = ...
                fileparts(projectDirectoryName);

            if projectParent ~= "" || projectName + projectExt ~= projectDirectoryName
                error( ...
                    "OpenMebius2:ProjectCreate:InvalidProjectDirectoryName", ...
                    "Project directory name must not contain path separators.");
            end

            if templateModelDirectory == "" || ~isfolder(templateModelDirectory)
                error( ...
                    "OpenMebius2:ProjectCreate:TemplateDirectoryNotFound", ...
                    "Template model directory does not exist: %s", ...
                    templateModelDirectory);
            end

        end

        function cleanupIncompleteProject(projectDirectory)

            if projectDirectory == "" || ~isfolder(projectDirectory)
                return
            end

            try
                rmdir(projectDirectory, "s");
            catch
            end

        end

    end

end
