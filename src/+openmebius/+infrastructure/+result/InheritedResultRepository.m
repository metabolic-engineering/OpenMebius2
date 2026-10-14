classdef InheritedResultRepository
    % Stores an independent snapshot of the original optimization only.
    methods
        function snapshot = readSource(obj, location, id, fallbackConfig, fallbackExperiments, options)
            arguments
                obj
                location
                id
                fallbackConfig
                fallbackExperiments
                options.ProgressReporter (1, 1) function_handle = @(~) []
            end
            options.ProgressReporter("Reading the saved optimization settings...");
            file = location.resultFile(id);
            if ~isfile(file)
                error('OpenMebius2:Inheritance:MissingResult', ...
                    'Batch %s has no result to inherit.', id);
            end
            % Keep the HDF5 metadata cache alive across dataset reads. Opening
            % and closing this file for each of thousands of iterations makes
            % large result snapshots disproportionately slow.
            fileId = H5F.open(file, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
            fileCleanup = onCleanup(@() H5F.close(fileId));
            status = h5read(file, '/status');
            if numel(status) < 2 || ~all(status(1:2))
                error('OpenMebius2:Inheritance:IncompleteOptimization', ...
                    'Batch %s has no completed optimization to inherit.', id);
            end
            repository = openmebius.infrastructure.result.Hdf5ResultRepository();
            batch = repository.readBatchSnapshot(location, id);
            snapshot.Config = fallbackConfig;
            snapshot.Experiments = string(fallbackExperiments);
            if strlength(batch.ConfigJson) > 0
                snapshot.Config = jsondecode(batch.ConfigJson);
            end
            if ~isempty(batch.Experiments)
                snapshot.Experiments = batch.Experiments;
            end
            snapshot.Config = openmebius.domain.batch.BatchConfig.normalize(snapshot.Config);
            snapshot.SourceID = string(id);
            snapshot.Data = struct;
            paths = {'MDVExp', 'MDVFragList', 'MDVFragMask', 'RSS', ...
                'RSSIndex', 'threshold'};
            for index = 1:numel(paths)
                name = paths{index};
                snapshot.Data.(name) = h5read(file, ['/' name]);
            end
            for name = ["model", "fluxVariability", "initialFlux", "fluxResult"]
                snapshot.Data.(name) = obj.readGroup(file, fileId, "/" + name, options.ProgressReporter);
            end
            % Require full (including reverse) fluxes and initial right-hand
            % sides now, before adding any batch or writing its snapshot.
            data = snapshot.Data;
            if isempty(data.initialFlux.rhs) || isempty(data.initialFlux.flux) || ...
                    isempty(data.RSSIndex) || ~isfinite(data.RSS(1))
                error('OpenMebius2:Inheritance:InvalidOptimization', ...
                    'Batch %s has invalid optimization data.', id);
            end
            for index = reshape(data.RSSIndex, 1, [])
                iteration = data.fluxResult.(sprintf('iteration%04d', index));
                if isempty(iteration.flux) || isempty(iteration.MDV)
                    error('OpenMebius2:Inheritance:InvalidOptimization', ...
                        'Batch %s is missing an optimization iteration.', id);
                end
            end
            snapshot.ModelHash = obj.optional(file, '/metadata/model/sha256');
            snapshot.ExperimentHashes = obj.optional(file, '/metadata/experiments/sha256');
        end

        function save(~, location, id, snapshot, options)
            arguments
                ~
                location
                id
                snapshot
                options.ProgressReporter (1, 1) function_handle = @(~) []
            end
            options.ProgressReporter("Saving the inherited optimization...");
            file = location.inheritanceFile(id);
            folder = fileparts(file);
            if ~isfolder(folder)
                mkdir(folder);
            end
            if isfile(file)
                error('OpenMebius2:Inheritance:SnapshotExists', ...
                    'An inherited result already exists for batch %s.', id);
            end
            temporary = string(tempname(folder)) + '.mat';
            cleanup = onCleanup(@() openmebius.infrastructure.result ...
                .InheritedResultRepository.deleteIfPresent(temporary));
            % v7 stores the nested iteration structs compactly, without
            % creating an HDF5 group for every MATLAB field. Retain v7.3 for
            % snapshots approaching the v7 per-variable size limit.
            details = whos('snapshot');
            if details.bytes < 1.5 * 1024^3
                save(temporary, 'snapshot', '-v7');
            else
                save(temporary, 'snapshot', '-v7.3');
            end
            [ok, message] = movefile(temporary, file);
            if ~ok
                error('OpenMebius2:Inheritance:SaveFailed', '%s', message);
            end
        end

        function snapshot = load(~, location, id)
            file = location.inheritanceFile(id);
            if ~isfile(file)
                error('OpenMebius2:Inheritance:MissingSnapshot', ...
                    'The inherited optimization snapshot for batch %s is missing.', id);
            end
            contents = load(file, 'snapshot');
            snapshot = contents.snapshot;
        end

        function isCanceled = writeOptimization(obj, file, data, id, options)
            arguments
                obj
                file
                data
                id
                options.ProgressReporter function_handle = @(~, ~) []
                options.CancellationRequested function_handle = @() false
            end
            isCanceled = options.CancellationRequested();
            if isCanceled
                return
            end
            % Reuse file/group handles for the whole snapshot. The general
            % dataset writer reopens the file several times per value, which
            % takes many minutes for tens of thousands of iteration datasets.
            if isfile(file)
                fileId = H5F.open(file, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
            else
                fileId = H5F.create(file, 'H5F_ACC_EXCL', 'H5P_DEFAULT', 'H5P_DEFAULT');
            end
            cleanup = onCleanup(@() H5F.close(fileId));
            obj.writeValue(fileId, 'ID', string(id));
            obj.writeValue(fileId, 'status', int8([0 0 0 0]));
            isCanceled = obj.writeGroup(fileId, '', data, options);
            if ~isCanceled
                obj.writeValue(fileId, 'status', int8([1 1 0 0]));
            end
        end
    end

    methods (Static)
        function validateInputs(snapshot, config, provenance)
            expected = snapshot.Config;
            expected.inheritedFrom = config.inheritedFrom;
            expected.status = config.status;
            expected.deleteResultFile = config.deleteResultFile;
            allowed = openmebius.domain.batch.InheritedBatchConfig ...
                .preserveOptimization(expected, config);
            if openmebius.domain.batch.BatchIdentity.canonicalJson(allowed) ~= ...
                    openmebius.domain.batch.BatchIdentity.canonicalJson(config)
                error('OpenMebius2:Inheritance:ChangedConfiguration', ...
                    'Optimization settings cannot change on an inherited batch.');
            end
            % Workbook byte hashes are provenance, not input equivalence:
            % saving unchanged Excel tables can change ZIP metadata and the
            % hash. Compare the saved scientific inputs in the restore
            % workflow, after fragment selection and efflux-free preparation.
            if isfield(snapshot, 'Experiments') && isfield(provenance, 'experimentNames') && ...
                    ~isequal(string(snapshot.Experiments(:)), string(provenance.experimentNames(:)))
                error('OpenMebius2:Inheritance:ChangedInputs', ...
                    'The experiment selection differs from the inherited result.');
            end
        end
    end

    methods (Static, Access = private)
        function data = readGroup(file, fileId, group, reporter)
            % Iterate links directly: h5info recursively builds metadata for
            % every dataset and becomes very slow for large iteration groups.
            groupId = H5G.open(fileId, group);
            cleanup = onCleanup(@() H5G.close(groupId));
            data = struct;
            count = 0;
            groupInfo = H5G.get_info(groupId);
            H5L.iterate(groupId, 'H5_INDEX_NAME', 'H5_ITER_NATIVE', 0, @readMember, []);

            function [status, unused] = readMember(parentId, name, unused)
                child = group + '/' + string(name);
                objectId = H5O.open(parentId, name, 'H5P_DEFAULT');
                objectCleanup = onCleanup(@() H5O.close(objectId));
                info = H5O.get_info(objectId);
                if info.type == H5ML.get_constant_value('H5O_TYPE_GROUP')
                    field = string(name);
                    if group == "/fluxResult"
                        field = "iteration" + field;
                    end
                    data.(field) = openmebius.infrastructure.result ...
                        .InheritedResultRepository.readGroup(file, fileId, child, reporter);
                else
                    value = H5D.read(objectId);
                    if ischar(value) || iscell(value)
                        value = h5read(file, child);
                    end
                    data.(name) = value;
                end
                count = count + 1;
                if group == "/fluxResult" && (mod(count, 100) == 0 || count == groupInfo.nlinks)
                    reporter(sprintf('Reading optimization results (%d/%d)...', count, groupInfo.nlinks));
                end
                status = 0;
            end
        end

        function isCanceled = writeGroup(groupId, group, data, options)
            names = fieldnames(data);
            isIterations = string(group) == "/fluxResult";
            if isIterations
                options.ProgressReporter(0, numel(names));
            end
            isCanceled = false;
            for index = 1:numel(names)
                if options.CancellationRequested()
                    isCanceled = true;
                    return
                end
                name = names{index};
                part = string(name);
                if isIterations
                    part = extractAfter(part, "iteration");
                end
                path = string(group) + '/' + part;
                value = data.(name);
                if isstruct(value)
                    if H5L.exists(groupId, part, 'H5P_DEFAULT')
                        childId = H5G.open(groupId, part);
                    else
                        childId = H5G.create(groupId, part, ...
                            'H5P_DEFAULT', 'H5P_DEFAULT', 'H5P_DEFAULT');
                    end
                    cleanup = onCleanup(@() H5G.close(childId));
                    isCanceled = openmebius.infrastructure.result.InheritedResultRepository ...
                        .writeGroup(childId, path, value, options);
                    clear cleanup
                    if isCanceled
                        return
                    end
                else
                    openmebius.infrastructure.result.InheritedResultRepository ...
                        .writeValue(groupId, part, value);
                end
                if isIterations && (mod(index, 500) == 0 || index == numel(names))
                    options.ProgressReporter(index, numel(names));
                end
            end
            isCanceled = options.CancellationRequested();
        end

        function writeValue(groupId, name, value)
            if iscell(value) || ischar(value)
                value = string(value);
            end
            switch class(value)
                case 'string'
                    typeId = H5T.copy('H5T_C_S1');
                    typeCleanup = onCleanup(@() H5T.close(typeId));
                    H5T.set_cset(typeId, H5ML.get_constant_value('H5T_CSET_UTF8'));
                    H5T.set_size(typeId, 'H5T_VARIABLE');
                    H5T.set_strpad(typeId, 'H5T_STR_NULLTERM');
                case 'double'
                    typeId = 'H5T_NATIVE_DOUBLE';
                case 'single'
                    typeId = 'H5T_NATIVE_FLOAT';
                case {'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64'}
                    typeId = ['H5T_NATIVE_' upper(class(value))];
                otherwise
                    error('OpenMebius2:Inheritance:UnsupportedType', ...
                        'Cannot restore dataset %s with type %s.', name, class(value));
            end
            spaceId = H5S.create_simple(ndims(value), fliplr(size(value)), []);
            spaceCleanup = onCleanup(@() H5S.close(spaceId));
            if H5L.exists(groupId, name, 'H5P_DEFAULT')
                H5L.delete(groupId, name, 'H5P_DEFAULT');
            end
            datasetId = H5D.create(groupId, name, typeId, spaceId, 'H5P_DEFAULT');
            datasetCleanup = onCleanup(@() H5D.close(datasetId));
            if ~isempty(value)
                H5D.write(datasetId, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', value);
            end
        end

        function value = optional(file, path)
            try
                value = string(h5read(file, path));
            catch
                value = strings(0, 1);
            end
        end

        function deleteIfPresent(file)
            if isfile(file)
                delete(file);
            end
        end
    end
end
