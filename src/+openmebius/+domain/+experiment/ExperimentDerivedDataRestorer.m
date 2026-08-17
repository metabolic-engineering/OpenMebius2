classdef ExperimentDerivedDataRestorer
    % EXPERIMENTDERIVEDDATARESTORER Validates optional stored derived data.

    properties (Access = private)
        Calculator
    end

    methods

        function obj = ExperimentDerivedDataRestorer(options)

            arguments
                options.Calculator = openmebius.domain.experiment ...
                    .ExperimentMDVCalculator()
            end

            obj.Calculator = options.Calculator;

        end % constructor

        function result = restore(obj, options)

            arguments
                obj
                options.MSNormalized table = table()
                options.MDV table = table()
                options.MDVBiomass table = table()
                options.MDVOptimization table = table()
                options.Enrichment table = table()
                options.ModelMSTable table = table()
                options.TargetMetabolites string = strings(0, 1)
            end

            mdvBiomass = options.MDVBiomass;
            mdvErrors = false(1, width(mdvBiomass));
            selection = table();
            enrichmentErrors = false(height(options.Enrichment), 1);
            warnings = strings(2, 1);
            numWarnings = 0;

            if ~isempty(mdvBiomass)

                try
                    [mdvBiomass, mdvErrors] = ...
                        obj.Calculator.validateBiomassMDV(mdvBiomass);
                    selection = obj.Calculator.createFragmentSelection( ...
                        mdvBiomass, ...
                        mdvErrors, ...
                        options.ModelMSTable, ...
                        options.TargetMetabolites);
                catch ME
                    mdvErrors = true(1, width(mdvBiomass));
                    numWarnings = numWarnings + 1;
                    warnings(numWarnings) = ...
                        "The stored biomass-corrected MDV sheet " + ...
                        "could not be validated: " + string(ME.message);
                end

            end

            if ~isempty(options.Enrichment)

                try
                    enrichmentErrors = ...
                        openmebius.domain.experiment ...
                        .ExperimentDerivedDataRestorer ...
                        .validateEnrichment(options.Enrichment);
                catch ME
                    enrichmentErrors = true( ...
                        height(options.Enrichment), ...
                        1);
                    numWarnings = numWarnings + 1;
                    warnings(numWarnings) = ...
                        "The stored enrichment sheet could not be " + ...
                        "validated: " + string(ME.message);
                end

            end

            result = openmebius.domain.experiment ...
                .StoredExperimentDerivedData( ...
                MSNormalized = options.MSNormalized, ...
                MDV = options.MDV, ...
                MDVBiomass = mdvBiomass, ...
                MDVOptimization = options.MDVOptimization, ...
                MDVErrors = mdvErrors, ...
                Enrichment = options.Enrichment, ...
                EnrichmentErrors = enrichmentErrors, ...
                Selection = selection, ...
                Warnings = warnings(1:numWarnings));

        end % restore

    end % methods

    methods (Static, Access = private)

        function errors = validateEnrichment(enrichment)

            values = enrichment{:, :};

            if ~isnumeric(values)
                error( ...
                    "OpenMebius2:ExperimentDerivedDataRestorer:" + ...
                    "InvalidEnrichmentType", ...
                    "Stored enrichment values must be numeric.");
            end

            errors = any( ...
                values < 0 | values > 1 | isnan(values), ...
                2);

        end % validateEnrichment

    end % methods (Static, Access = private)

end % classdef
