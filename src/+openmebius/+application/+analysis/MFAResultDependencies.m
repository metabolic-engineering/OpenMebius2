classdef MFAResultDependencies
    % MFARESULTDEPENDENCIES Resolved result persistence services.

    properties (SetAccess = private)
        MFAInputSnapshotWriter
        MFAResultCheckpointWriter
        NextLabelResultCheckpointWriter
        MFAResultCoordinator
    end

    methods

        function obj = MFAResultDependencies(options)

            arguments
                options.MFAInputSnapshotWriter = []
                options.MFAResultCheckpointWriter = []
                options.NextLabelResultCheckpointWriter = []
                options.MFAResultCoordinator = []
            end

            obj.MFAInputSnapshotWriter = ...
                options.MFAInputSnapshotWriter;
            obj.MFAResultCheckpointWriter = ...
                options.MFAResultCheckpointWriter;
            obj.NextLabelResultCheckpointWriter = ...
                options.NextLabelResultCheckpointWriter;
            obj.MFAResultCoordinator = options.MFAResultCoordinator;

        end

    end

end
