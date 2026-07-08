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

    end % methods

    methods (Static)

        function obj = fromDirectory(directory)

            obj = openmebius.domain.experiment.ExperimentLocation( ...
                string(directory));

        end % fromDirectory

    end % methods (Static)

end % classdef
