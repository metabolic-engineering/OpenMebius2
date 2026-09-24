classdef ExperimentComparisonBuilder
    % EXPERIMENTCOMPARISONBUILDER Builds cross-experiment comparison tables.

    methods

        function result = buildMSNormalized(obj, collection, fragmentName)

            result = obj.buildFragment( ...
                collection, ...
                "tableMSNormalized", ...
                fragmentName, ...
                "The MS normalized table is not available.");

        end % buildMSNormalized

        function result = buildMDVBiomass(obj, collection, fragmentName)

            result = obj.buildFragment( ...
                collection, ...
                "tableMDVBiomass", ...
                fragmentName, ...
                "The MDV biomass table is not available.");

        end % buildMDVBiomass

        function result = buildEnrichment(obj, collection)

            arguments
                obj
                collection openmebius.domain.experiment ...
                    .ExperimentCollection
            end

            [data, missingExperiments] = obj.combineSingleColumn( ...
                collection, "tableEnrichment");

            if collection.Count == 0
                result = obj.unavailableResult( ...
                    "No experiment data is available.");
                return
            end

            if isempty(data)
                result = obj.unavailableResult( ...
                    "Enrichment is unavailable for all experiments: " + ...
                    join(missingExperiments, ", ") + ". " + ...
                    "Verify ODi, ODf, and biomass-corrected MDV data, " + ...
                    "then calculate MDV again.");
                return
            end

            values = data{:, :};
            errorMask = values < 0 | values > 1 | isnan(values);
            message = "";

            if ~isempty(missingExperiments)
                message = ...
                    "Enrichment is unavailable for: " + ...
                    join(missingExperiments, ", ") + ". " + ...
                    "Missing values are shown in the table. " + ...
                    "Verify ODi, ODf, and biomass-corrected MDV data.";
            end

            result = openmebius.domain.experiment ...
                .ExperimentComparisonResult( ...
                Data = data, ...
                ErrorMask = errorMask, ...
                Message = message);

        end % buildEnrichment

        function result = buildSelection(obj, collection)

            arguments
                obj
                collection openmebius.domain.experiment ...
                    .ExperimentCollection
            end

            selected = table();
            available = table();

            if collection.Count == 0
                result = obj.unavailableSelection( ...
                    "No experiment data is available.");
                return
            end

            for iExperiment = 1:collection.Count
                fieldName = collection.FieldNames(iExperiment);
                experiment = collection.Data.(fieldName);

                if ~isfield(experiment, "tableSelection") || ...
                        isempty(experiment.tableSelection)
                    result = obj.unavailableSelection( ...
                        "The fragment selection table is not available. " + ...
                        "Press Calculate MDV before configuring " + ...
                        "MDV-dependent analysis.");
                    return
                end

                experimentName = collection.FileBaseNames(iExperiment);
                selectedColumn = obj.prepareColumn( ...
                    experiment.tableSelection(:, "Select"), ...
                    experimentName);
                availableColumn = obj.prepareColumn( ...
                    experiment.tableSelection(:, "Available"), ...
                    experimentName);
                selected = obj.joinColumns(selected, selectedColumn);
                available = obj.joinColumns(available, availableColumn);
            end

            result = openmebius.domain.experiment ...
                .ExperimentSelectionComparison( ...
                Selected = obj.restoreRowNames(selected), ...
                Available = obj.restoreRowNames(available));

        end % buildSelection

    end % methods

    methods (Access = private)

        function result = buildFragment( ...
                obj, collection, tableField, fragmentName, missingMessage)

            arguments
                obj
                collection openmebius.domain.experiment ...
                    .ExperimentCollection
                tableField (1, 1) string
                fragmentName (1, 1) string
                missingMessage (1, 1) string
            end

            combined = table();

            if collection.Count == 0
                result = obj.unavailableResult( ...
                    "No experiment data is available.");
                return
            end

            for iExperiment = 1:collection.Count
                fieldName = collection.FieldNames(iExperiment);
                experiment = collection.Data.(fieldName);

                if ~isfield(experiment, tableField) || ...
                        isempty(experiment.(tableField))
                    result = obj.unavailableResult(missingMessage);
                    return
                end

                source = experiment.(tableField);

                if ~ismember(fragmentName, ...
                        string(source.Properties.VariableNames))
                    result = obj.unavailableResult( ...
                        "The fragment " + fragmentName + ...
                        " is not available in " + ...
                        collection.FileBaseNames(iExperiment) + ".");
                    return
                end

                column = obj.prepareColumn( ...
                    source(:, fragmentName), ...
                    collection.FileBaseNames(iExperiment));
                combined = obj.joinColumns(combined, column);
            end

            combined = obj.restoreRowNames(combined);
            values = combined{:, :};
            emptyRows = all(isnan(values) | values == 0, 2);
            combined(emptyRows, :) = [];
            result = openmebius.domain.experiment ...
                .ExperimentComparisonResult(Data = combined);

        end % buildFragment

        function [combined, missingExperiments] = combineSingleColumn( ...
                obj, collection, tableField)

            combined = table();
            missingExperiments = strings(0, 1);

            for iExperiment = 1:collection.Count
                fieldName = collection.FieldNames(iExperiment);
                experiment = collection.Data.(fieldName);

                if ~isfield(experiment, tableField) || ...
                        isempty(experiment.(tableField))
                    missingExperiments(end + 1, 1) = ...
                        collection.FileBaseNames(iExperiment);
                    continue
                end

                column = obj.prepareColumn( ...
                    experiment.(tableField), ...
                    collection.FileBaseNames(iExperiment));
                combined = obj.joinColumns(combined, column);
            end

            combined = obj.restoreRowNames(combined);

            if isempty(combined)
                return
            end

            for iExperiment = 1:collection.Count
                experimentName = collection.FileBaseNames(iExperiment);

                if ismember( ...
                        experimentName, ...
                        string(combined.Properties.VariableNames))
                    continue
                end

                combined.(experimentName) = nan(height(combined), 1);
            end

            combined = combined(:, collection.FileBaseNames);

        end % combineSingleColumn

        function column = prepareColumn(~, column, experimentName)

            if width(column) ~= 1
                error( ...
                    "OpenMebius2:ExperimentComparisonBuilder:" + ...
                    "ExpectedSingleColumn", ...
                    "Comparison source must contain exactly one column.");
            end

            column.Properties.VariableNames = experimentName;
            column.RowNamesTemp = string(column.Properties.RowNames);

        end % prepareColumn

        function combined = joinColumns(~, combined, column)

            if isempty(combined)
                combined = column;
                return
            end

            combined = outerjoin( ...
                combined, ...
                column, ...
                'Keys', "RowNamesTemp", ...
                'MergeKeys', true);

        end % joinColumns

        function data = restoreRowNames(~, data)

            if isempty(data) && ...
                    ~ismember("RowNamesTemp", ...
                    string(data.Properties.VariableNames))
                return
            end

            if ismember("RowNamesTemp", ...
                    string(data.Properties.VariableNames))
                data.Properties.RowNames = cellstr(string(data.RowNamesTemp));
                data = removevars(data, "RowNamesTemp");
            end

        end % restoreRowNames

        function result = unavailableResult(~, message)

            result = openmebius.domain.experiment ...
                .ExperimentComparisonResult( ...
                IsAvailable = false, ...
                Message = message);

        end % unavailableResult

        function result = unavailableSelection(~, message)

            result = openmebius.domain.experiment ...
                .ExperimentSelectionComparison( ...
                IsAvailable = false, ...
                Message = message);

        end % unavailableSelection

    end % methods (Access = private)

end % classdef
