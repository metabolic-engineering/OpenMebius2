classdef ResultComparisonCatalog
    % RESULTCOMPARISONCATALOG Analyzed batches available for comparison.

    properties (SetAccess = private)
        BatchIDs (:, 1) string
        BatchNames (:, 1) string
        ExperimentNames (:, 1) string
        Contents (:, 1) string
    end

    methods

        function obj = ResultComparisonCatalog(options)

            arguments
                options.BatchIDs (:, 1) string = strings(0, 1)
                options.BatchNames (:, 1) string = strings(0, 1)
                options.ExperimentNames (:, 1) string = strings(0, 1)
                options.Contents (:, 1) string = strings(0, 1)
            end

            lengths = [ ...
                numel(options.BatchIDs), ...
                numel(options.BatchNames), ...
                numel(options.ExperimentNames), ...
                numel(options.Contents)];

            if numel(unique(lengths)) ~= 1
                error( ...
                    "OpenMebius2:ResultComparison:CatalogSizeMismatch", ...
                    "Comparison catalog columns must have equal lengths.");
            end

            obj.BatchIDs = options.BatchIDs;
            obj.BatchNames = options.BatchNames;
            obj.ExperimentNames = options.ExperimentNames;
            obj.Contents = options.Contents;

        end % constructor

        function names = namesFor(obj, batchIDs)

            arguments
                obj
                batchIDs (:, 1) string
            end

            [isPresent, indices] = ismember(batchIDs, obj.BatchIDs);

            if ~all(isPresent)
                missingID = batchIDs(find(~isPresent, 1));
                error( ...
                    "OpenMebius2:ResultComparison:UnknownBatch", ...
                    "Batch '%s' is not available for comparison.", ...
                    missingID);
            end

            names = obj.BatchNames(indices);

        end % namesFor

        function count = count(obj)

            count = numel(obj.BatchIDs);

        end % count

    end % methods

end % classdef
