classdef ResultBatchRecoveryService
    % RESULTBATCHRECOVERYSERVICE Restores missing batch rows from results.

    methods

        function recoveredIds = recover(~, batch, result)

            recoveredIds = strings(0, 1);

            if ~isobject(batch) || ~isobject(result) || ...
                    ~ismethod(batch, 'getBatchForGUI') || ...
                    ~ismethod(batch, 'recoverBatches') || ...
                    ~ismethod(result, 'getResultIDs') || ...
                    ~ismethod(result, 'getBatchSnapshots')
                return
            end

            batchTable = batch.getBatchForGUI();
            resultIds = string(result.getResultIDs());
            missingIds = setdiff( ...
                resultIds(:), string(batchTable.ID), 'stable');

            if isempty(missingIds)
                return
            end

            snapshots = result.getBatchSnapshots(missingIds);
            entries = cell(numel(snapshots), 1);
            entryCount = 0;

            for index = 1:numel(snapshots)

                if isempty(snapshots{index})
                    continue
                end

                entryCount = entryCount + 1;
                entries{entryCount, 1} = ...
                    openmebius.application.result ...
                    .ResultBatchRecoveryService.toEntry( ...
                    snapshots{index}, missingIds(index));
            end

            entries = entries(1:entryCount);

            if ~isempty(entries)
                recoveredIds = batch.recoverBatches(entries);
            end

        end % recover

    end % methods

    methods (Static, Access = private)

        function entry = toEntry(snapshot, fallbackId)

            id = openmebius.application.result ...
                .ResultBatchRecoveryService.fieldString( ...
                snapshot, 'ID', fallbackId);
            experiments = strings(0, 1);

            if isfield(snapshot, 'Experiments')
                experiments = string(snapshot.Experiments(:));
                experiments = experiments(strlength(experiments) > 0);
            end

            name = openmebius.application.result ...
                .ResultBatchRecoveryService.fieldString( ...
                snapshot, 'Name', "");

            if strlength(name) == 0 && ~isempty(experiments)
                name = strjoin(experiments, " + ");
            elseif strlength(name) == 0
                name = "Recovered result";
            end

            config = struct;
            configJson = openmebius.application.result ...
                .ResultBatchRecoveryService.fieldString( ...
                snapshot, 'ConfigJson', "");

            if strlength(configJson) > 0

                try
                    config = jsondecode(char(configJson));
                catch
                    config = struct;
                end

            end

            config = openmebius.domain.batch.BatchConfig.normalize(config);
            status = lower(openmebius.application.result ...
                .ResultBatchRecoveryService.fieldString( ...
                snapshot, 'Status', "finished"));

            if ~ismember(status, ["finished", "error", "canceled"])
                status = "finished";
            end

            config.status = char(status);
            entry = struct( ...
                'ID', id, ...
                'Name', name, ...
                'Experiments', experiments, ...
                'Description', openmebius.application.result ...
                .ResultBatchRecoveryService.fieldString( ...
                snapshot, 'Description', ""), ...
                'Config', config, ...
                'ContentHash', openmebius.application.result ...
                .ResultBatchRecoveryService.fieldString( ...
                snapshot, 'ContentHash', ""));

        end % toEntry

        function value = fieldString(data, fieldName, defaultValue)

            value = string(defaultValue);

            if isfield(data, fieldName) && ~isempty(data.(fieldName))
                candidate = string(data.(fieldName));
                value = candidate(1);
            end

        end % fieldString

    end % methods (Static, Access = private)

end % classdef
