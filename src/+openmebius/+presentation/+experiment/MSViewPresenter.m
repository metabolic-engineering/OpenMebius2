classdef MSViewPresenter < handle
    % MSVIEWPRESENTER Selects experiment data for the MS viewer.

    properties (Access = private)
        Experiments
    end

    methods

        function obj = MSViewPresenter(experiments)

            if isempty(experiments) || ...
                    (isa(experiments, 'handle') && ~isvalid(experiments))
                error( ...
                    "OpenMebius2:MSViewPresenter:InvalidExperiments", ...
                    "Experiment data must be a valid object.");
            end

            obj.Experiments = experiments;

        end % constructor

        function names = experimentNames(obj)

            names = string(obj.Experiments.getExpList());
            names = names(:).';

        end % experimentNames

        function name = experimentNameAt(obj, index)

            arguments
                obj (1, 1) openmebius.presentation.experiment.MSViewPresenter
                index (1, 1) double {mustBeInteger, mustBePositive}
            end

            names = obj.experimentNames();

            if index > numel(names)
                error( ...
                    "OpenMebius2:MSViewPresenter:InvalidExperimentIndex", ...
                    "Experiment index %d is outside the available range.", ...
                    index);
            end

            name = names(index);

        end % experimentNameAt

        function tf = hasCalculatedMDV(obj)

            tf = logical(obj.Experiments.hasCalculatedMDV());

        end % hasCalculatedMDV

        function viewModel = presentTable(obj, experimentName, tableType)

            arguments
                obj (1, 1) openmebius.presentation.experiment.MSViewPresenter
                experimentName (1, 1) string
                tableType (1, 1) string
            end

            import openmebius.presentation.experiment.MSViewTableViewModel

            switch tableType
                case "MS raw data"
                    viewModel = MSViewTableViewModel( ...
                        Data = obj.Experiments.getMSTable(experimentName));
                case "MS normarized data"
                    viewModel = MSViewTableViewModel( ...
                        Data = obj.Experiments.getMSNormalizedTable( ...
                        experimentName));
                case "MDV (Mass distribution vectors)"
                    viewModel = MSViewTableViewModel( ...
                        Data = obj.Experiments.getMDVTable(experimentName));
                case "Biomass corrected MDV"
                    [data, errorColumns] = ...
                        obj.Experiments.getMDVBiomassTable(experimentName);
                    viewModel = MSViewTableViewModel( ...
                        Data = data, ...
                        ErrorColumns = logical(errorColumns(:).'));
                case "Enrichment"
                    [data, errorMask] = ...
                        obj.Experiments.getEnrichmentComparison();
                    viewModel = MSViewTableViewModel( ...
                        Data = data, ...
                        ExperimentSelectionEnabled = false, ...
                        UseHeatmap = true, ...
                        ErrorMask = logical(errorMask));
                otherwise
                    error( ...
                        "OpenMebius2:MSViewPresenter:UnknownTableType", ...
                        "Unknown MS view table type: %s", ...
                        tableType);
            end

        end % presentTable

    end % methods

end % classdef
