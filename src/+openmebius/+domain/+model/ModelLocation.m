classdef ModelLocation
    % MODELLOCATION
    % Resolves files that belong to a model directory.

    properties (SetAccess = private)
        Directory (1, 1) string
    end

    methods

        function obj = ModelLocation(directory)

            arguments
                directory (1, 1) string
            end

            obj.Directory = string(directory);

        end % constructor

        function path = modelFile(obj, fileName, fileType)

            path = fullfile(obj.Directory, string(fileName) + "." + string(fileType));

        end % modelFile

        function path = labelFile(obj, fileName, fileType)

            path = fullfile(obj.Directory, string(fileName) + "." + string(fileType));

        end % labelFile

        function path = pathwayFile(obj, fileName, fileType)

            path = fullfile(obj.Directory, string(fileName) + "." + string(fileType));

        end % pathwayFile

        function path = hashFile(obj, fileName)

            path = fullfile(obj.Directory, string(fileName) + ".hash");

        end % hashFile

        function path = cacheFile(obj, fileName)

            path = fullfile(obj.Directory, string(fileName) + ".mat");

        end % cacheFile

    end % methods

    methods (Static)

        function obj = fromInput(input)

            if isa(input, 'openmebius.domain.model.ModelLocation')
                obj = input;
                return;
            end

            obj = openmebius.domain.model.ModelLocation.fromDirectory( ...
                string(input));

        end % fromInput

        function obj = fromDirectory(directory)

            obj = openmebius.domain.model.ModelLocation(string(directory));

        end % fromDirectory

    end % methods (Static)

end % classdef
