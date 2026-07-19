classdef ProjectMetadata

    properties (SetAccess = private)

        Name (1, 1) string
        Author (1, 1) string
        Organism (1, 1) string

    end

    methods

        function obj = ProjectMetadata(options)

            arguments
                options.Name (1, 1) string = ""
                options.Author (1, 1) string = ""
                options.Organism (1, 1) string = ""
            end

            obj.Name = options.Name;
            obj.Author = options.Author;
            obj.Organism = options.Organism;

        end % constructor

        function s = toStruct(obj)

            s = struct();
            s.Name = obj.Name;
            s.Author = obj.Author;
            s.Organism = obj.Organism;

        end % method toStruct

    end % methods

    methods (Static)

        function obj = fromStruct(s)

            required = ["Name", "Author", "Organism"];

            for i = 1:numel(required)

                if ~isfield(s, required(i))
                    error( ...
                        "OpenMebius2:Project:InvalidMetadata", ...
                        "Project metadata does not contain field '%s'.", ...
                        required(i));
                end

            end

            obj = openmebius.domain.project.ProjectMetadata( ...
                Name = string(s.Name), ...
                Author = string(s.Author), ...
                Organism = string(s.Organism));

        end % method fromStruct

    end % methods (Static)

end % classdef
