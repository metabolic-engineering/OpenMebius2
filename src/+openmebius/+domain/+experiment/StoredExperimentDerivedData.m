classdef StoredExperimentDerivedData
    % STOREDEXPERIMENTDERIVEDDATA Optional derived data restored from storage.

    properties (SetAccess = private)
        MSNormalized table
        MDV table
        MDVBiomass table
        MDVErrors (1, :) logical
        Enrichment table
        EnrichmentErrors (:, 1) logical
        Selection table
        Warnings (:, 1) string
    end

    methods

        function obj = StoredExperimentDerivedData(options)

            arguments
                options.MSNormalized table = table()
                options.MDV table = table()
                options.MDVBiomass table = table()
                options.MDVErrors (1, :) logical = false(1, 0)
                options.Enrichment table = table()
                options.EnrichmentErrors (:, 1) logical = false(0, 1)
                options.Selection table = table()
                options.Warnings (:, 1) string = strings(0, 1)
            end

            if width(options.MDVBiomass) ~= numel(options.MDVErrors)
                error( ...
                    "OpenMebius2:StoredExperimentDerivedData:" + ...
                    "InvalidMDVErrors", ...
                "MDVErrors must contain one value per MDV column.");
            end

            if height(options.Enrichment) ~= ...
                    numel(options.EnrichmentErrors)
                error( ...
                    "OpenMebius2:StoredExperimentDerivedData:" + ...
                    "InvalidEnrichmentErrors", ...
                "EnrichmentErrors must contain one value per row.");
            end

            obj.MSNormalized = options.MSNormalized;
            obj.MDV = options.MDV;
            obj.MDVBiomass = options.MDVBiomass;
            obj.MDVErrors = options.MDVErrors;
            obj.Enrichment = options.Enrichment;
            obj.EnrichmentErrors = options.EnrichmentErrors;
            obj.Selection = options.Selection;
            obj.Warnings = unique(options.Warnings(:), "stable");

        end % constructor

    end % methods

end % classdef
