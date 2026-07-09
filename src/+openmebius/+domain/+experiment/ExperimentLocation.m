classdef ExperimentLocation
    % EXPERIMENTLOCATION
    % Identifies the directory that contains experiment workbooks.

    properties (SetAccess = private)
        Directory (1, 1) string
    end

    methods

        function obj = ExperimentLocation(directory)

            arguments
                directory (1, 1) string
            end

            obj.Directory = string(directory);

        end % constructor

        function path = workbookFile(obj, fileName)

            path = fullfile(obj.Directory, string(fileName));

        end % workbookFile

        function path = batchFile(obj, fileName)

            path = fullfile(obj.Directory, string(fileName));

        end % batchFile

        function name = experimentName(~, fileName)

            [~, name] = fileparts(string(fileName));
            name = string(name);

        end % experimentName

        function files = filesByType(obj, fileType)

            listing = dir(fullfile(obj.Directory, "*." + string(fileType)));
            files = string({listing.name});

        end % filesByType

    end % methods

    methods (Static)

        function obj = fromInput(input)

            if isa(input, 'openmebius.domain.experiment.ExperimentLocation')
                obj = input;
                return;
            end

            obj = openmebius.domain.experiment.ExperimentLocation ...
                .fromDirectory(string(input));

        end % fromInput

        function obj = fromDirectory(directory)

            obj = openmebius.domain.experiment.ExperimentLocation( ...
                string(directory));

        end % fromDirectory

    end % methods (Static)

end % classdef
