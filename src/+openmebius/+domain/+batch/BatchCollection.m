classdef BatchCollection < handle
    % BATCHCOLLECTION Owns batch entries and their identity-based updates.

    properties (Access = private)
        TableData table
    end

    methods

        function obj = BatchCollection(batchTable)

            arguments
                batchTable table
            end

            requiredVariables = ...
                ["id", "name", "exp", "description", "config", ...
                 "contentHash"];
            actualVariables = string(batchTable.Properties.VariableNames);

            if ~all(ismember(requiredVariables, actualVariables))
                error( ...
                    "OpenMebius2:BatchCollection:InvalidSchema", ...
                    "Batch table does not contain the required variables.");
            end

            obj.TableData = batchTable;

        end % constructor

        function batchTable = toTable(obj)

            batchTable = obj.TableData;

        end % toTable

        function ids = finishedIds(obj)

            isFinished = false(height(obj.TableData), 1);

            for i = 1:height(obj.TableData)
                isFinished(i) = ...
                    string(obj.TableData.config(i).status) == "finished";
            end

            ids = obj.TableData.id(isFinished);

        end % finishedIds

        function config = configFor(obj, id)

            arguments
                obj (1, 1) openmebius.domain.batch.BatchCollection
                id (1, 1) string
            end

            config = obj.TableData.config(obj.indexOf(id));

        end % configFor

        function experimentList = experimentsFor(obj, ids)

            arguments
                obj (1, 1) openmebius.domain.batch.BatchCollection
                ids string
            end

            indices = obj.indicesOf(ids);
            chunks = cell(numel(indices), 1);

            for i = 1:numel(indices)
                experimentNames = string(obj.TableData.exp{indices(i)});
                chunks{i} = experimentNames(:);
            end

            if isempty(chunks)
                experimentList = strings(0, 1);
            else
                experimentList = vertcat(chunks{:});
            end

        end % experimentsFor

        function statuses = statusesFor(obj, ids)

            arguments
                obj (1, 1) openmebius.domain.batch.BatchCollection
                ids string
            end

            ids = string(ids(:));
            statuses = strings(size(ids));

            for i = 1:numel(ids)
                index = find(obj.TableData.id == ids(i), 1);

                if isempty(index)
                    statuses(i) = "unknown";
                else
                    statuses(i) = ...
                        string(obj.TableData.config(index).status);
                end
            end

        end % statusesFor

        function replaceConfigs(obj, ids, config)

            arguments
                obj (1, 1) openmebius.domain.batch.BatchCollection
                ids string
                config (1, 1) struct
            end

            indices = obj.indicesOf(ids);
            config = openmebius.domain.batch.BatchConfig.normalize(config);

            for i = 1:numel(indices)
                obj.TableData.config(indices(i)) = config;
            end

        end % replaceConfigs

        function setStatus(obj, ids, status)

            arguments
                obj (1, 1) openmebius.domain.batch.BatchCollection
                ids string
                status (1, 1) string {mustBeMember(status, ...
                    ["ready", "finished", "error", "warning", ...
                     "canceled"])}
            end

            indices = obj.indicesOf(ids);

            for i = 1:numel(indices)
                obj.TableData.config(indices(i)).status = char(status);
            end

        end % setStatus

        function id = add(obj, name, experiments, description, config)

            arguments
                obj (1, 1) openmebius.domain.batch.BatchCollection
                name (1, 1) string
                experiments (1, 1) cell
                description (1, 1) string
                config (1, 1) struct
            end

            config = openmebius.domain.batch.BatchConfig.normalize(config);
            id = openmebius.domain.batch.BatchIdentity.newId( ...
                obj.TableData.id);
            row = cell2table( ...
                {id, name, experiments, description, config, ""}, ...
                'VariableNames', obj.TableData.Properties.VariableNames);
            row.Properties.VariableTypes = ...
                obj.TableData.Properties.VariableTypes;

            if isempty(obj.TableData)
                obj.TableData = row;
            else
                obj.TableData = [obj.TableData; row];
            end

        end % add

        function edit(obj, id, name, experiments, description, config)

            arguments
                obj (1, 1) openmebius.domain.batch.BatchCollection
                id (1, 1) string
                name (1, 1) string
                experiments (1, 1) cell
                description (1, 1) string
                config (1, 1) struct
            end

            openmebius.domain.batch.BatchConfig.validate(config);
            index = obj.indexOf(id);
            obj.TableData.name(index) = name;
            obj.TableData.exp(index) = experiments;
            obj.TableData.description(index) = description;
            obj.TableData.config(index) = config;

        end % edit

        function [removed, reason] = remove(obj, id)

            arguments
                obj (1, 1) openmebius.domain.batch.BatchCollection
                id (1, 1) string
            end

            removed = false;
            reason = "";
            index = find(obj.TableData.id == id, 1);

            if isempty(index)
                reason = "missing";
                return
            end

            if string(obj.TableData.config(index).status) == "finished"
                reason = "finished";
                return
            end

            obj.TableData(index, :) = [];
            removed = true;

        end % remove

        function clearUnfinished(obj)

            finished = false(height(obj.TableData), 1);

            for i = 1:height(obj.TableData)
                finished(i) = ...
                    string(obj.TableData.config(i).status) == "finished";
            end

            obj.TableData = obj.TableData(finished, :);

        end % clearUnfinished

    end % methods

    methods (Access = private)

        function index = indexOf(obj, id)

            index = find(obj.TableData.id == string(id), 1);

            if isempty(index)
                error( ...
                    "OpenMebius2:BatchCollection:BatchNotFound", ...
                    "Batch ID not found: %s", ...
                    id);
            end

        end % indexOf

        function indices = indicesOf(obj, ids)

            ids = string(ids(:));
            [found, indices] = ismember(ids, obj.TableData.id);

            if ~all(found)
                missingId = ids(find(~found, 1));
                error( ...
                    "OpenMebius2:BatchCollection:BatchNotFound", ...
                    "Batch ID not found: %s", ...
                    missingId);
            end

        end % indicesOf

    end % methods (Access = private)

end % classdef
