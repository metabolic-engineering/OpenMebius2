classdef MFAResultComposition
    % MFARESULTCOMPOSITION Configures result persistence services.

    properties (SetAccess = private)
        Hdf5ResultRepository
        MFAInputSnapshotWriter
        MFAResultCheckpointWriter
        NextLabelResultCheckpointWriter
        MFAResultCoordinator
        ResultManifestRepository
    end

    methods

        function obj = MFAResultComposition(options)

            arguments
                options.Hdf5ResultRepository = ...
                    openmebius.infrastructure.result ...
                    .Hdf5ResultRepository()
                options.MFAInputSnapshotWriter = []
                options.MFAResultCheckpointWriter = []
                options.NextLabelResultCheckpointWriter = []
                options.MFAResultCoordinator = []
                options.ResultManifestRepository = ...
                    openmebius.infrastructure.result ...
                    .ResultManifestRepository()
            end

            obj.Hdf5ResultRepository = ...
                options.Hdf5ResultRepository;
            obj.MFAInputSnapshotWriter = ...
                options.MFAInputSnapshotWriter;
            obj.MFAResultCheckpointWriter = ...
                options.MFAResultCheckpointWriter;
            obj.NextLabelResultCheckpointWriter = ...
                options.NextLabelResultCheckpointWriter;
            obj.MFAResultCoordinator = options.MFAResultCoordinator;
            obj.ResultManifestRepository = ...
                options.ResultManifestRepository;

        end

    end

end
