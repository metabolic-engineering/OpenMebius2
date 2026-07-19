classdef ProjectArtifacts
    % PROJECTARTIFACTS Runtime objects restored for one project session.

    properties (SetAccess = private)
        Model
        Experiments
        Batch
        Result
        Messages (:, 1) string
    end

    methods

        function obj = ProjectArtifacts(options)

            arguments
                options.Model
                options.Experiments
                options.Batch
                options.Result
                options.Messages string = strings(0, 1)
            end

            obj.Model = options.Model;
            obj.Experiments = options.Experiments;
            obj.Batch = options.Batch;
            obj.Result = options.Result;
            obj.Messages = options.Messages(:);

        end

    end

end
