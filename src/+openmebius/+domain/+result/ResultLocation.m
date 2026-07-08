classdef ResultLocation
    % RESULTLOCATION
    % Identifies the directory that contains result files.

    properties (SetAccess = private)
        Directory (1, 1) string
    end

    methods

        function obj = ResultLocation(directory)

            arguments
                directory (1, 1) string
            end

            obj.Directory = string(directory);

        end % constructor

        function path = resultFile(obj, id)

            path = fullfile(obj.Directory, string(id) + ".h5");

        end % resultFile

    end % methods

    methods (Static)

        function obj = fromDirectory(directory)

            obj = openmebius.domain.result.ResultLocation(string(directory));

        end % fromDirectory

    end % methods (Static)

end % classdef
