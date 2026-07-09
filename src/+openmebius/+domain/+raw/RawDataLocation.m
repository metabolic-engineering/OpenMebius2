classdef RawDataLocation
    % RAWDATALOCATION
    % Resolves files that belong to a raw MS data directory.

    properties (SetAccess = private)
        Directory (1, 1) string
    end

    methods

        function obj = RawDataLocation(directory)

            arguments
                directory (1, 1) string
            end

            obj.Directory = string(directory);

        end % constructor

        function path = textFile(obj, fileName)

            path = fullfile(obj.Directory, string(fileName));

        end % textFile

        function files = textFiles(obj)

            listing = dir(fullfile(obj.Directory, "*.txt"));
            files = string({listing.name});

        end % textFiles

    end % methods

    methods (Static)

        function obj = fromInput(input)

            if isa(input, 'openmebius.domain.raw.RawDataLocation')
                obj = input;
                return;
            end

            obj = openmebius.domain.raw.RawDataLocation.fromDirectory( ...
                string(input));

        end % fromInput

        function obj = fromDirectory(directory)

            obj = openmebius.domain.raw.RawDataLocation(string(directory));

        end % fromDirectory

    end % methods (Static)

end % classdef
