classdef ProjectOperationResult
    % PROJECTOPERATIONRESULT Project session and optional runtime artifacts.

    properties (SetAccess = private)
        Session openmebius.domain.project.ProjectSession
        Artifacts = []
        Messages (:, 1) string
    end

    methods

        function obj = ProjectOperationResult(options)

            arguments
                options.Session openmebius.domain.project.ProjectSession
                options.Artifacts = []
                options.Messages (:, 1) string = strings(0, 1)
            end

            obj.Session = options.Session;
            obj.Artifacts = options.Artifacts;
            obj.Messages = options.Messages;

        end % constructor

    end % methods

end % classdef
