classdef ResultComparisonCatalogService < handle
    % RESULTCOMPARISONCATALOGSERVICE Finds analyzed batches with ranges.

    methods

        function catalog = load(~, batch, result)

            openmebius.application.result.ResultComparisonCatalogService ...
                .validateDependency(batch, "Batch");
            openmebius.application.result.ResultComparisonCatalogService ...
                .validateDependency(result, "Result");

            batchTable = getBatchForGUI(batch);
            requiredVariables = ["ID", "Name", "Experiment"];

            if ~istable(batchTable) || ...
                    ~all(ismember( ...
                    requiredVariables, ...
                    string(batchTable.Properties.VariableNames)))
                error( ...
                    "OpenMebius2:ResultComparison:InvalidBatchTable", ...
                "Batch data does not contain ID, Name, and Experiment.");
            end

            batchIDs = string(batchTable.ID);
            statuses = string(getBatchStatus(batch, batchIDs));
            finished = statuses(:) == "finished";
            batchTable = batchTable(finished, :);
            batchIDs = string(batchTable.ID);

            if isempty(batchIDs)
                catalog = openmebius.application.result ...
                    .ResultComparisonCatalog();
                return
            end

            [resultData, resultMask] = loadResultFiles( ...
                result, ...
                batchIDs(:)', ...
                readstatus = false(1, 4));
            resultMask = logical(resultMask(:));
            resultData = resultData(resultMask);
            batchTable = batchTable(resultMask, :);

            contents = strings(numel(resultData), 1);
            isAnalyzed = false(numel(resultData), 1);

            for dataIndex = 1:numel(resultData)
                status = logical(resultData{dataIndex}.status(:));
                hasFVA = numel(status) >= 1 && status(1);
                hasCI = numel(status) >= 3 && status(3);

                if hasCI
                    contents(dataIndex) = "CI";
                    isAnalyzed(dataIndex) = true;
                elseif hasFVA
                    contents(dataIndex) = "FVA";
                    isAnalyzed(dataIndex) = true;
                end

            end

            batchTable = batchTable(isAnalyzed, :);
            contents = contents(isAnalyzed);

            catalog = openmebius.application.result ...
                .ResultComparisonCatalog( ...
                BatchIDs = string(batchTable.ID), ...
                BatchNames = string(batchTable.Name), ...
                ExperimentNames = string(batchTable.Experiment), ...
                Contents = contents);

        end % load

    end % methods

    methods (Static, Access = private)

        function validateDependency(value, name)

            isInvalidHandle = isa(value, "handle") && ~isvalid(value);

            if isempty(value) || isInvalidHandle
                error( ...
                    "OpenMebius2:ResultComparison:Invalid" + name, ...
                    "%s data is not available.", name);
            end

        end % validateDependency

    end % methods (Static, Access = private)

end % classdef
