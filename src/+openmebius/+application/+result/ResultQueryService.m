classdef ResultQueryService
    % RESULTQUERYSERVICE Reads result data independently of UI state.

    properties (Access = private)
        Location openmebius.domain.result.ResultLocation
        ResultRepository
        Hdf5ResultRepository
    end

    methods

        function obj = ResultQueryService(location, options)

            arguments
                location (1, 1) openmebius.domain.result.ResultLocation
                options.ResultRepository = ...
                    openmebius.infrastructure.result.ResultRepository()
                options.Hdf5ResultRepository = ...
                    openmebius.infrastructure.result.Hdf5ResultRepository()
            end

            obj.Location = location;
            obj.ResultRepository = options.ResultRepository;
            obj.Hdf5ResultRepository = options.Hdf5ResultRepository;
        end

        function assertAvailable(obj)
            obj.ResultRepository.assertResultDirectory(obj.Location);
        end

        function data = read(obj, id, options)

            arguments
                obj
                id (1, 1) string
                options.ReadStatus (1, 4) logical = true(1, 4)
            end

            obj.assertAvailable();

            if ~obj.Location.hasResultFile(id)
                data = [];
                return
            end

            data = obj.Hdf5ResultRepository.readResultData( ...
                obj.Location, id, ReadStatus = options.ReadStatus);
        end

        function [data, mask] = readMany(obj, ids, options)

            arguments
                obj
                ids (1, :) string
                options.ReadStatus (1, 4) logical = true(1, 4)
            end

            obj.assertAvailable();
            data = cell(1, numel(ids));
            mask = false(1, numel(ids));

            for index = 1:numel(ids)
                data{index} = obj.read( ...
                    ids(index), ReadStatus = options.ReadStatus);
                mask(index) = ~isempty(data{index});
            end

        end

        function snapshots = readBatchSnapshots(obj, ids)

            arguments
                obj
                ids string
            end

            obj.assertAvailable();
            ids = string(ids(:));
            snapshots = cell(numel(ids), 1);

            for index = 1:numel(ids)

                try
                    snapshots{index} = obj.Hdf5ResultRepository ...
                        .readBatchSnapshot(obj.Location, ids(index));
                catch
                    % A corrupt result must not prevent other batches
                    % from being restored when the project is opened.
                end

            end

        end

        function data = readConfidenceInterval(obj, id, reactionID)

            arguments
                obj
                id (1, 1) string
                reactionID (1, 1) string
            end

            obj.assertAvailable();

            if ~obj.Location.hasResultFile(id)
                data = [];
                return
            end

            data = obj.Hdf5ResultRepository.readConfidenceInterval( ...
                obj.Location, id, reactionID);
        end

        function data = readOptimizationState(obj, id)

            arguments
                obj
                id (1, 1) string
            end

            obj.assertAvailable();

            if ~obj.Location.hasResultFile(id)
                data = [];
                return
            end

            data = obj.Hdf5ResultRepository.readOptimizationState( ...
                obj.Location, id);

        end

        function [exists, data] = readNextLabelSuggestion(obj, id)

            arguments
                obj
                id (1, 1) string
            end

            obj.assertAvailable();
            [exists, data] = obj.Hdf5ResultRepository ...
                .readNextLabelSuggestion(obj.Location, id);
        end

    end

end
