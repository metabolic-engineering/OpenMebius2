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

        function path = reportFile(obj, fileName)

            path = obj.artifactFile(fileName);

        end % reportFile

        function path = summaryReportFile(obj)

            path = obj.reportFile("summary");

        end % summaryReportFile

        function tf = hasDirectory(obj)

            tf = obj.Directory ~= "";

        end % hasDirectory

        function tf = directoryExists(obj)

            tf = obj.hasDirectory() && isfolder(obj.Directory);

        end % directoryExists

        function path = artifactFile(obj, fileName)

            path = fullfile(obj.Directory, string(fileName));

        end % artifactFile

        function location = childLocation(obj, directoryName)

            location = openmebius.domain.result.ResultLocation.fromDirectory( ...
                fullfile(obj.Directory, string(directoryName)));

        end % childLocation

        function tf = hasResultFile(obj, id)

            tf = isfile(obj.resultFile(id));

        end % hasResultFile

        function files = resultFiles(obj)

            files = dir(fullfile(obj.Directory, "*.h5"));

        end % resultFiles

    end % methods

    methods (Static)

        function obj = fromInput(input)

            if isa(input, 'openmebius.domain.result.ResultLocation')
                obj = input;
                return;
            end

            obj = openmebius.domain.result.ResultLocation.fromDirectory( ...
                string(input));

        end % fromInput

        function obj = fromDirectory(directory)

            obj = openmebius.domain.result.ResultLocation(string(directory));

        end % fromDirectory

    end % methods (Static)

end % classdef
