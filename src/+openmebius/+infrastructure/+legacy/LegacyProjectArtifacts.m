classdef LegacyProjectArtifacts
    % LEGACYPROJECTARTIFACTS
    % Container for existing OpenMebius2 legacy objects.
    %
    % This object intentionally wraps legacy classes:
    %   EMUModel
    %   IOExps
    %   Batch
    %   IOResult

    properties (SetAccess = private)
        Model
        Experiments
        Batch
        Result
        Messages string
    end

    methods

        function obj = LegacyProjectArtifacts(options)

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
