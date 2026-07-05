classdef OpenProjectUseCase < handle

    properties (Access = private)
        Repository openmebius.infrastructure.project.FileProjectRepository
    end

    methods

        function obj = OpenProjectUseCase(repository)

            arguments
                repository openmebius.infrastructure.project.FileProjectRepository
            end

            obj.Repository = repository;

        end

        function session = execute(obj, projectDirectory)

            arguments
                obj
                projectDirectory (1, 1) string
            end

            projectDirectory = strtrim(projectDirectory);

            if projectDirectory == ""
                error( ...
                    "OpenMebius2:Project:EmptyProjectDirectory", ...
                "Project directory is empty.");
            end

            session = obj.Repository.openProject(projectDirectory);

        end

    end

end
