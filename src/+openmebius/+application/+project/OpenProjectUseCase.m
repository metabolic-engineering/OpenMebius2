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

        function session = execute(obj, projectInput)

            arguments
                obj
                projectInput (1, 1) string
            end

            projectInput = strtrim(projectInput);

            if projectInput == ""
                error( ...
                    "OpenMebius2:Project:EmptyProjectDirectory", ...
                "Project directory is empty.");
            end

            session = obj.Repository.openProject(projectInput);

        end

    end

end
