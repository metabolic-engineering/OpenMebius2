classdef ProjectSession < handle

    properties (SetAccess = private)
        Metadata openmebius.domain.project.ProjectMetadata
        Paths openmebius.domain.project.ProjectPaths
    end

    methods

        function obj = ProjectSession(metadata, paths)

            arguments
                metadata openmebius.domain.project.ProjectMetadata
                paths openmebius.domain.project.ProjectPaths
            end

            obj.Metadata = metadata;
            obj.Paths = paths;

        end

        function root = rootDirectory(obj)
            root = obj.Paths.RootDirectory;
        end

    end

end
