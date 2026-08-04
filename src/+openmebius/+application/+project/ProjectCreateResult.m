classdef ProjectCreateResult

    properties (SetAccess = private)
        Session openmebius.domain.project.ProjectSession
        Messages (:, 1) string
    end

    methods

        function obj = ProjectCreateResult(options)

            arguments
                options.Session openmebius.domain.project.ProjectSession
                options.Messages (:, 1) string = strings(0, 1)
            end

            obj.Session = options.Session;
            obj.Messages = options.Messages;

        end

    end

end
