classdef ProjectMigrationService
    % PROJECTMIGRATIONSERVICE Writes canonical metadata for older projects.

    properties (Access = private)
        Repository
    end

    methods

        function obj = ProjectMigrationService(repository)
            arguments
                repository
            end
            obj.Repository = repository;
        end

        function session = migrate(obj, session)
            arguments
                obj
                session (1, 1) openmebius.domain.project.ProjectSession
            end

            obj.Repository.saveProject(session);
        end

    end

end
