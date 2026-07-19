classdef LabelConfigurationUpdateResult
    % LABELCONFIGURATIONUPDATERESULT Result of applying label settings.

    properties (SetAccess = private)
        Messages (:, 1) string
    end

    methods

        function obj = LabelConfigurationUpdateResult(options)

            arguments
                options.Messages (:, 1) string = strings(0, 1)
            end

            obj.Messages = options.Messages;

        end % constructor

    end % methods

end % classdef
