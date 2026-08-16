classdef ExperimentComparisonService < handle
    % EXPERIMENTCOMPARISONSERVICE Builds data for comparison views.

    properties (Access = private)
        Builder
    end

    methods

        function obj = ExperimentComparisonService(options)

            arguments
                options.Builder = openmebius.domain.experiment ...
                    .ExperimentComparisonBuilder()
            end

            obj.Builder = options.Builder;

        end % constructor

        function catalog = loadCatalog(obj, experiments)

            collection = obj.collectionFrom(experiments);
            enrichment = obj.Builder.buildEnrichment(collection);
            obj.assertAvailable(enrichment);
            dataNames = string(enrichment.Data.Properties.RowNames).';

            if isempty(dataNames)
                error( ...
                    "OpenMebius2:ExperimentComparison:Unavailable", ...
                    "No comparison data is available.");
            end

            catalog = openmebius.application.experiment ...
                .ExperimentComparisonCatalog( ...
                ExperimentNames = collection.FileBaseNames, ...
                DataNames = dataNames);

        end % loadCatalog

        function selection = loadSelection( ...
                obj, experiments, experimentNames, dataNames)

            arguments
                obj
                experiments
                experimentNames
                dataNames
            end

            experimentNames = reshape(string(experimentNames), 1, []);
            dataNames = reshape(string(dataNames), 1, []);

            if isempty(experimentNames) || isempty(dataNames)
                error( ...
                    "OpenMebius2:ExperimentComparison:SelectionRequired", ...
                    "Select at least one experiment and one data item.");
            end

            collection = obj.collectionFrom(experiments);

            if ~all(ismember(experimentNames, collection.FileBaseNames))
                error( ...
                    "OpenMebius2:ExperimentComparison:UnknownExperiment", ...
                    "The comparison contains an unknown experiment.");
            end

            tables = cell(numel(dataNames), 1);

            for dataIndex = 1:numel(dataNames)
                comparison = obj.Builder.buildMDVBiomass( ...
                    collection, dataNames(dataIndex));
                obj.assertAvailable(comparison);
                tables{dataIndex} = comparison.Data(:, experimentNames);
            end

            selection = openmebius.application.experiment ...
                .ExperimentComparisonSelection( ...
                ExperimentNames = experimentNames, ...
                DataNames = dataNames, ...
                Tables = tables);

        end % loadSelection

    end % methods

    methods (Access = private)

        function collection = collectionFrom(~, experiments)

            if isempty(experiments) || ...
                    (isa(experiments, "handle") && ~isvalid(experiments))
                error( ...
                    "OpenMebius2:ExperimentComparison:InvalidExperiments", ...
                    "Experiment data is not valid.");
            end

            if ~ismethod(experiments, "getCollection")
                error( ...
                    "OpenMebius2:ExperimentComparison:UnsupportedExperiments", ...
                    "Experiment data must provide getCollection.");
            end

            collection = experiments.getCollection();

        end % collectionFrom

        function assertAvailable(~, comparison)

            if comparison.IsAvailable
                return
            end

            message = comparison.Message;

            if message == ""
                message = "Comparison data is not available.";
            end

            error( ...
                "OpenMebius2:ExperimentComparison:Unavailable", ...
                "%s", ...
                message);

        end % assertAvailable

    end % methods (Access = private)

end % classdef
