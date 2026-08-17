classdef DuplicateProjectUseCase < handle
    % DUPLICATEPROJECTUSECASE Copies a project and updates its metadata.

    properties (Access = private)
        Repository
    end

    methods

        function obj = DuplicateProjectUseCase(repository)

            obj.Repository = repository;

        end % constructor

        function result = execute(obj, options)

            arguments
                obj
                options.SourceSession (1, 1) ...
                    openmebius.domain.project.ProjectSession
                options.ParentDirectory (1, 1) string
                options.ProjectDirectoryName (1, 1) string
            end

            sourceSession = options.SourceSession;
            parentDirectory = strtrim(options.ParentDirectory);
            projectDirectoryName = strtrim(options.ProjectDirectoryName);

            sourceSession.Paths.assertExists();
            openmebius.application.project.DuplicateProjectUseCase ...
                .validateDestination( ...
                sourceSession.Paths.RootDirectory, ...
                parentDirectory, ...
                projectDirectoryName);

            sourceDirectory = sourceSession.Paths.RootDirectory;
            projectDirectory = fullfile( ...
                parentDirectory, projectDirectoryName);

            try
                [ok, message] = copyfile( ...
                    sourceDirectory, projectDirectory);

                if ~ok
                    error( ...
                        "OpenMebius2:ProjectDuplicate:CopyFailed", ...
                        "Failed to duplicate project: %s", ...
                        string(message));
                end

                metadata = openmebius.domain.project.ProjectMetadata( ...
                    Name = projectDirectoryName, ...
                    Author = sourceSession.Metadata.Author, ...
                    Organism = sourceSession.Metadata.Organism);
                paths = openmebius.domain.project.ProjectPaths( ...
                    projectDirectory);
                session = openmebius.domain.project.ProjectSession( ...
                    metadata, paths);
                obj.Repository.saveProject(session);

            catch exception
                openmebius.application.project.DuplicateProjectUseCase ...
                    .cleanupIncompleteProject(projectDirectory);
                rethrow(exception)
            end

            result = openmebius.application.project ...
                .ProjectDuplicateResult( ...
                Session = session, ...
                Messages = "Project duplicated to " + projectDirectory);

        end % execute

    end % methods

    methods (Static, Access = private)

        function validateDestination( ...
                sourceDirectory, parentDirectory, projectDirectoryName)

            if parentDirectory == ""
                error( ...
                    "OpenMebius2:ProjectDuplicate:EmptyParentDirectory", ...
                    "Project parent directory is empty.");
            end

            if ~isfolder(parentDirectory)
                error( ...
                    "OpenMebius2:ProjectDuplicate:ParentDirectoryNotFound", ...
                    "Project parent directory does not exist: %s", ...
                    parentDirectory);
            end

            if projectDirectoryName == ""
                error( ...
                    "OpenMebius2:ProjectDuplicate:EmptyProjectName", ...
                    "Project name cannot be empty.");
            end

            [projectParent, projectName, projectExtension] = ...
                fileparts(projectDirectoryName);

            if projectParent ~= "" || ...
                    projectName + projectExtension ~= projectDirectoryName
                error( ...
                    "OpenMebius2:ProjectDuplicate:InvalidProjectName", ...
                    "Project name must not contain path separators.");
            end

            projectDirectory = fullfile( ...
                parentDirectory, projectDirectoryName);

            if isfolder(projectDirectory) || isfile(projectDirectory)
                error( ...
                    "OpenMebius2:ProjectDuplicate:DirectoryAlreadyExists", ...
                    "Project destination already exists: %s", ...
                    projectDirectory);
            end

            sourcePath = openmebius.application.project ...
                .DuplicateProjectUseCase.canonicalPath(sourceDirectory);
            destinationPath = openmebius.application.project ...
                .DuplicateProjectUseCase.canonicalPath(projectDirectory);

            if ispc
                sourcePath = lower(sourcePath);
                destinationPath = lower(destinationPath);
            end

            if destinationPath == sourcePath || startsWith( ...
                    destinationPath, sourcePath + string(filesep))
                error( ...
                    "OpenMebius2:ProjectDuplicate:DestinationInsideSource", ...
                    "Project destination cannot be inside the current project.");
            end

        end % validateDestination

        function path = canonicalPath(path)

            try
                path = string(java.io.File(char(path)).getCanonicalPath());
            catch
                path = string(path);
            end

        end % canonicalPath

        function cleanupIncompleteProject(projectDirectory)

            if projectDirectory == "" || ~isfolder(projectDirectory)
                return
            end

            try
                rmdir(projectDirectory, "s");
            catch
            end

        end % cleanupIncompleteProject

    end % methods (Static, Access = private)

end % classdef
