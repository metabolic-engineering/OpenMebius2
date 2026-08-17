classdef ProjectOperationController < handle
    % PROJECTOPERATIONCONTROLLER Runs project open, save, create, and
    % duplicate use cases.

    properties (Access = private)
        Repository
        OpenProjectUseCase
        CreateProjectUseCase
        DuplicateProjectUseCase
        ArtifactRepository
        MigrationService
    end

    methods

        function obj = ProjectOperationController(options)

            arguments
                options.Repository = []
                options.OpenProjectUseCase = []
                options.CreateProjectUseCase = []
                options.DuplicateProjectUseCase = []
                options.ArtifactRepository = []
                options.MigrationService = []
            end

            repository = options.Repository;

            if isempty(repository)
                repository = openmebius.infrastructure.project ...
                    .FileProjectRepository();
            end

            openProjectUseCase = options.OpenProjectUseCase;

            if isempty(openProjectUseCase)
                openProjectUseCase = openmebius.application.project ...
                    .OpenProjectUseCase(repository);
            end

            createProjectUseCase = options.CreateProjectUseCase;

            if isempty(createProjectUseCase)
                createProjectUseCase = openmebius.application.project ...
                    .CreateProjectUseCase(repository);
            end

            duplicateProjectUseCase = options.DuplicateProjectUseCase;

            if isempty(duplicateProjectUseCase)
                duplicateProjectUseCase = openmebius.application.project ...
                    .DuplicateProjectUseCase(repository);
            end

            artifactRepository = options.ArtifactRepository;

            if isempty(artifactRepository)
                artifactRepository = openmebius.infrastructure.project ...
                    .ProjectArtifactRepository();
            end

            migrationService = options.MigrationService;

            if isempty(migrationService)
                migrationService = openmebius.application.project ...
                    .ProjectMigrationService(repository);
            end

            obj.Repository = repository;
            obj.OpenProjectUseCase = openProjectUseCase;
            obj.CreateProjectUseCase = createProjectUseCase;
            obj.DuplicateProjectUseCase = duplicateProjectUseCase;
            obj.ArtifactRepository = artifactRepository;
            obj.MigrationService = migrationService;

        end % constructor

        function outcome = open(obj, projectInput)

            arguments
                obj
                projectInput (1, 1) string
            end

            outcome = obj.execute(@openProject);

            function result = openProject()

                session = obj.OpenProjectUseCase.execute(projectInput);
                session = obj.MigrationService.migrate(session);
                artifacts = obj.ArtifactRepository.load(session);
                result = openmebius.application.project ...
                    .ProjectOperationResult( ...
                    Session = session, ...
                    Artifacts = artifacts, ...
                    Messages = artifacts.Messages);

            end

        end % open

        function outcome = save( ...
                obj, currentSession, projectInput, metadata)

            arguments
                obj
                currentSession
                projectInput (1, 1) string
                metadata openmebius.domain.project.ProjectMetadata
            end

            outcome = obj.execute(@saveProject);

            function result = saveProject()

                session = currentSession;

                if ~obj.isValidSession(session)
                    session = obj.OpenProjectUseCase.execute(projectInput);
                end

                session = openmebius.domain.project.ProjectSession( ...
                    metadata, ...
                    session.Paths);
                obj.Repository.saveProject(session);

                messages = "Project setting saved to " + ...
                    session.Paths.SettingFile + ...
                    " and " + ...
                    session.Paths.LegacySettingFile;
                result = openmebius.application.project ...
                    .ProjectOperationResult( ...
                    Session = session, ...
                    Messages = messages);

            end

        end % save

        function outcome = create(obj, options)

            arguments
                obj
                options.ParentDirectory (1, 1) string
                options.ProjectDirectoryName (1, 1) string
                options.TemplateModelDirectory (1, 1) string
                options.Metadata openmebius.domain.project.ProjectMetadata
            end

            outcome = obj.execute(@createProject);

            function result = createProject()

                createResult = obj.CreateProjectUseCase.execute( ...
                    ParentDirectory = options.ParentDirectory, ...
                    ProjectDirectoryName = options.ProjectDirectoryName, ...
                    TemplateModelDirectory = options.TemplateModelDirectory, ...
                    Metadata = options.Metadata);
                artifacts = obj.ArtifactRepository.load( ...
                    createResult.Session, AllowEmptyExperiments = true);
                result = openmebius.application.project ...
                    .ProjectOperationResult( ...
                    Session = createResult.Session, ...
                    Artifacts = artifacts, ...
                    Messages = [ ...
                    createResult.Messages
                    artifacts.Messages]);

            end

        end % create

        function outcome = duplicate(obj, currentSession, options)

            arguments
                obj
                currentSession
                options.ParentDirectory (1, 1) string
                options.ProjectDirectoryName (1, 1) string
            end

            outcome = obj.execute(@duplicateProject);

            function result = duplicateProject()

                duplicateResult = obj.DuplicateProjectUseCase.execute( ...
                    SourceSession = currentSession, ...
                    ParentDirectory = options.ParentDirectory, ...
                    ProjectDirectoryName = options.ProjectDirectoryName);
                result = openmebius.application.project ...
                    .ProjectOperationResult( ...
                    Session = duplicateResult.Session, ...
                    Messages = duplicateResult.Messages);

            end

        end % duplicate

    end % methods

    methods (Access = private)

        function outcome = execute(~, command)

            try
                result = command();
                outcome = openmebius.application.project ...
                    .ProjectOperationOutcome( ...
                    true, Result = result);
            catch exception
                outcome = openmebius.application.project ...
                    .ProjectOperationOutcome( ...
                    false, ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);
            end

        end % execute

        function tf = isValidSession(~, session)

            tf = ~isempty(session) && ...
                isa(session, 'openmebius.domain.project.ProjectSession');

            if ~tf
                return
            end

            try
                tf = isvalid(session);
            catch
                tf = false;
            end

        end % isValidSession

    end % methods (Access = private)

end % classdef
