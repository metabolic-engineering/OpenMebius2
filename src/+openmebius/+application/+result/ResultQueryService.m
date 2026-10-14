classdef ResultQueryService < handle
    % RESULTQUERYSERVICE Reads result data independently of UI state.

    properties (Access = private)
        Location openmebius.domain.result.ResultLocation
        ResultRepository
        Hdf5ResultRepository
        SummaryCache
        DetailCache
        CacheClock = 0
        MaxCacheBytes = 64 * 1024 * 1024
    end

    methods

        function obj = ResultQueryService(location, options)

            arguments
                location (1, 1) openmebius.domain.result.ResultLocation
                options.ResultRepository = ...
                    openmebius.infrastructure.result.ResultRepository()
                options.Hdf5ResultRepository = ...
                    openmebius.infrastructure.result.Hdf5ResultRepository()
                options.MaxCacheBytes (1, 1) double {mustBeNonnegative} = 64 * 1024 * 1024
            end

            obj.Location = location;
            obj.ResultRepository = options.ResultRepository;
            obj.Hdf5ResultRepository = options.Hdf5ResultRepository;
            obj.MaxCacheBytes = options.MaxCacheBytes;
            obj.SummaryCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.DetailCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
        end

        function invalidate(obj, ids)
            if nargin < 2 || isempty(ids)
                obj.SummaryCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
                obj.DetailCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
                return
            end
            ids = string(ids);
            for id = ids(:)'
                if isKey(obj.SummaryCache, char(id))
                    remove(obj.SummaryCache, char(id));
                end
            end
            cacheKeys = keys(obj.DetailCache);
            for index = 1:numel(cacheKeys)
                entry = obj.DetailCache(cacheKeys{index});
                if any(entry.ID == ids)
                    remove(obj.DetailCache, cacheKeys{index});
                end
            end
        end

        function [data, mask] = readSummaries(obj, ids)
            % One directory scan, then only changed or new HDF5 files.
            obj.assertAvailable();
            ids = string(ids(:)');
            files = obj.Location.resultFiles();
            names = string({files.name});
            [found, positions] = ismember(ids + ".h5", names);
            data = cell(size(ids));
            mask = false(size(ids));
            for index = 1:numel(ids)
                id = ids(index);
                if ~found(index)
                    obj.invalidate(id);
                    continue
                end
                signature = obj.fileSignature(files(positions(index)));
                try
                    key = char(id);
                    if isKey(obj.SummaryCache, key)
                        entry = obj.SummaryCache(key);
                        if isequal(entry.Signature, signature)
                            data{index} = entry.Data;
                            mask(index) = true;
                            continue
                        end
                        obj.invalidate(id);
                    end
                    item = obj.Hdf5ResultRepository.readResultSummary(obj.Location, id);
                    % Do not cache a snapshot taken while a writer changed the file.
                    if isequal(signature, obj.currentSignature(id))
                        obj.SummaryCache(key) = struct('Signature', signature, 'Data', item);
                    end
                    data{index} = item;
                    mask(index) = true;
                catch
                    % A missing/corrupt result does not hide the other rows.
                    obj.invalidate(id);
                end
            end
            stale = setdiff(string(keys(obj.SummaryCache)), erase(names, ".h5"));
            if ~isempty(stale)
                obj.invalidate(stale);
            end
        end

        function data = readBestFit(obj, id, options)
            arguments
                obj
                id (1, 1) string
                options.IncludeMDV (1, 1) logical = false
            end
            data = obj.cachedRead(id, "best-fit-" + string(options.IncludeMDV), ...
                @() obj.Hdf5ResultRepository.readBestFit(obj.Location, id, ...
                IncludeMDV = options.IncludeMDV));
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

            data = obj.cachedRead(id, "ci-" + reactionID, ...
                @() obj.Hdf5ResultRepository.readConfidenceInterval( ...
                obj.Location, id, reactionID));
        end

        function data = readOptimizationState(obj, id, options)

            arguments
                obj
                id (1, 1) string
                options.IncludeExitFlags (1, 1) logical = true
            end

            data = obj.cachedRead(id, "optimization-" + string(options.IncludeExitFlags), ...
                @() obj.Hdf5ResultRepository.readOptimizationState( ...
                obj.Location, id, IncludeExitFlags = options.IncludeExitFlags));

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

    methods (Access = private)

        function signature = currentSignature(obj, id)
            files = dir(obj.Location.resultFile(id));
            signature = obj.fileSignature(files);
        end

        function signature = fileSignature(~, files)
            signature = [];
            if ~isempty(files)
                signature = [files(1).bytes, files(1).datenum];
            end
        end

        function data = cachedRead(obj, id, kind, reader)
            obj.assertAvailable();
            signature = obj.currentSignature(id);
            if isempty(signature)
                obj.invalidate(id);
                data = [];
                return
            end
            key = jsonencode([id, kind]);
            obj.CacheClock = obj.CacheClock + 1;
            if isKey(obj.DetailCache, key)
                entry = obj.DetailCache(key);
                if isequal(entry.Signature, signature)
                    entry.Access = obj.CacheClock;
                    obj.DetailCache(key) = entry;
                    data = entry.Data;
                    return
                end
                obj.invalidate(id);
            end
            data = reader();
            info = whos('data');
            if isempty(data) || info.bytes > obj.MaxCacheBytes || ...
                    ~isequal(signature, obj.currentSignature(id))
                return
            end
            obj.DetailCache(key) = struct('ID', id, 'Signature', signature, ...
                'Data', data, 'Bytes', info.bytes, 'Access', obj.CacheClock);
            entries = values(obj.DetailCache);
            cacheKeys = keys(obj.DetailCache);
            sizes = cellfun(@(item) item.Bytes, entries);
            [~, order] = sort(cellfun(@(item) item.Access, entries));
            total = sum(sizes);
            for index = order
                if total <= obj.MaxCacheBytes
                    break
                end
                remove(obj.DetailCache, cacheKeys{index});
                total = total - sizes(index);
            end
        end

    end

end
