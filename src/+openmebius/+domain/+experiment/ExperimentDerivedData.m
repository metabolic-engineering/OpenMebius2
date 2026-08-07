classdef ExperimentDerivedData
    % EXPERIMENTDERIVEDDATA Calculated tables for one experiment.

    properties (SetAccess = private)
        MSNormalized table
        MDV table
        MDVBiomass table
        MDVOptimization table
        MDVErrors (1, :) logical
        Enrichment table
        EnrichmentErrors (:, 1) logical
        Selection table
        Warnings (:, 1) string
    end

    methods

        function obj = ExperimentDerivedData(options)

            arguments
                options.MSNormalized table
                options.MDV table
                options.MDVBiomass table
                options.MDVOptimization table = table()
                options.MDVErrors (1, :) logical
                options.Enrichment table
                options.EnrichmentErrors (:, 1) logical
                options.Selection table
                options.Warnings (:, 1) string = strings(0, 1)
            end

            if width(options.MDVBiomass) ~= numel(options.MDVErrors)
                error( ...
                    "OpenMebius2:ExperimentDerivedData:" + ...
                    "InvalidMDVErrors", ...
                "MDVErrors must contain one value per MDV column.");
            end

            if height(options.Enrichment) ~= ...
                    numel(options.EnrichmentErrors)
                error( ...
                    "OpenMebius2:ExperimentDerivedData:" + ...
                    "InvalidEnrichmentErrors", ...
                "EnrichmentErrors must contain one value per row.");
            end

            obj.MSNormalized = options.MSNormalized;
            obj.MDV = options.MDV;
            obj.MDVBiomass = options.MDVBiomass;
            obj.MDVOptimization = options.MDVOptimization;
            obj.MDVErrors = options.MDVErrors;
            obj.Enrichment = options.Enrichment;
            obj.EnrichmentErrors = options.EnrichmentErrors;
            obj.Selection = options.Selection;
            obj.Warnings = unique(options.Warnings(:), "stable");

        end % constructor

    end % methods

end % classdef
