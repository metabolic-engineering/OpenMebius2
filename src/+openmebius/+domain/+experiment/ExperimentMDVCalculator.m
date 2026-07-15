classdef ExperimentMDVCalculator
    % EXPERIMENTMDVCALCULATOR Builds MDV-derived data for one experiment.

    properties (SetAccess = private)
        MDVTolerance (1, 1) double
        NaturalIsotopeCorrectionMethod (1, 1) string
    end

    methods

        function obj = ExperimentMDVCalculator(options)

            arguments
                options.MDVTolerance (1, 1) double = -1e-2
                options.NaturalIsotopeCorrectionMethod (1, 1) string = ...
                    "skew"
            end

            obj.MDVTolerance = options.MDVTolerance;
            obj.NaturalIsotopeCorrectionMethod = ...
                options.NaturalIsotopeCorrectionMethod;

        end % constructor

        function result = calculate(obj, input)

            arguments
                obj
                input openmebius.domain.experiment ...
                    .ExperimentMDVCalculationInput
            end

            obj.assertExperimentInfo(input.ExperimentInfo);

            msNormalized = obj.normalizeMS(input.RawMS);
            mdv = obj.correctNaturalIsotopes( ...
                msNormalized, ...
                input.AtomTable, ...
                input.MSMetaboliteTable);
            mdvBiomass = obj.correctBiomass( ...
                mdv, ...
                input.ExperimentInfo);
            [mdvBiomass, mdvErrors] = ...
                obj.validateBiomassMDV(mdvBiomass);
            [enrichment, enrichmentErrors, warnings] = ...
                obj.createEnrichment( ...
                mdvBiomass, ...
                mdvErrors, ...
                input.MSMetaboliteTable);
            selection = obj.createFragmentSelection( ...
                mdvBiomass, ...
                mdvErrors, ...
                input.ModelMSTable, ...
                input.TargetMetabolites);

            result = openmebius.domain.experiment.ExperimentDerivedData( ...
                MSNormalized = msNormalized, ...
                MDV = mdv, ...
                MDVBiomass = mdvBiomass, ...
                MDVErrors = mdvErrors, ...
                Enrichment = enrichment, ...
                EnrichmentErrors = enrichmentErrors, ...
                Selection = selection, ...
                Warnings = warnings);

        end % calculate

        function [mdv, errors] = validateBiomassMDV(obj, mdvBiomass)

            arguments
                obj
                mdvBiomass table
            end

            numFragments = width(mdvBiomass);
            mdv = mdvBiomass;
            errors = false(1, numFragments);

            for iFragment = 1:numFragments
                fragment = mdvBiomass{:, iFragment};
                fragment(isnan(fragment)) = 0;

                if abs(sum(fragment) - 1) > 1e-6 || ...
                        any(fragment < obj.MDVTolerance)
                    errors(iFragment) = true;
                    continue
                end

                fragment(fragment < 0) = 0;
                mdv{:, iFragment} = fragment / sum(fragment);
            end

        end % validateBiomassMDV

        function selection = createFragmentSelection( ...
                ~, mdvBiomass, mdvErrors, modelMSTable, ...
                targetMetabolites)

            arguments
                ~
                mdvBiomass table
                mdvErrors (1, :) logical
                modelMSTable table
                targetMetabolites string
            end

            if width(mdvBiomass) ~= numel(mdvErrors)
                error( ...
                    "OpenMebius2:ExperimentMDVCalculator:" + ...
                    "InvalidMDVErrors", ...
                    "MDV errors must contain one value per MDV column.");
            end

            requiredVariables = "Used";
            if ~all(ismember( ...
                    requiredVariables, ...
                    string(modelMSTable.Properties.VariableNames)))
                error( ...
                    "OpenMebius2:ExperimentMDVCalculator:" + ...
                    "MissingModelMSVariables", ...
                    "The model MS table must contain a Used variable.");
            end

            targetInModel = sort(targetMetabolites(:));
            targetInMS = sort(string( ...
                modelMSTable.Properties.RowNames(:)));

            if ~isequal(targetInModel, targetInMS)
                error( ...
                    "OpenMebius2:ExperimentMDVCalculator:" + ...
                    "InvalidTargetList", ...
                    "The target metabolite list is not valid.");
            end

            selection = modelMSTable(:, "Used");
            selection.Properties.VariableNames = "Select";

            targetInExperiment = string( ...
                mdvBiomass.Properties.VariableNames(~mdvErrors));
            selection.Available = ismember( ...
                string(selection.Properties.RowNames), ...
                targetInExperiment);

        end % createFragmentSelection

    end % methods

    methods (Access = private)

        function msNormalized = normalizeMS(~, rawMS)

            msNormalized = rawMS;

            for iFragment = 1:width(msNormalized)
                fragment = msNormalized{:, iFragment};
                fragment(isnan(fragment)) = 0;
                msNormalized{:, iFragment} = fragment / sum(fragment);
            end

        end % normalizeMS

        function mdv = correctNaturalIsotopes( ...
                obj, msNormalized, atomTable, msMetaboliteTable)

            mdv = msNormalized;
            atomNames = string(atomTable.Properties.RowNames);
            correction = MDVCorrection();

            for iFragment = 1:width(mdv)
                fragment = msNormalized{:, iFragment};
                fragment(isnan(fragment)) = 0;
                fragmentName = string( ...
                    msNormalized.Properties.VariableNames{iFragment});
                atomIndex = find(atomNames == fragmentName, 1);

                if isempty(atomIndex)
                    mdv{:, iFragment} = nan(size(fragment));
                    continue
                end

                atom = atomTable(atomIndex, :);
                numTracerCarbon = obj.getNumTracerCarbon( ...
                    msMetaboliteTable, ...
                    fragmentName, ...
                    length(fragment));
                corrected = correction.correctNaturalIsotopoper( ...
                    fragment, ...
                    atom.C, ...
                    atom.H, ...
                    atom.O, ...
                    atom.N, ...
                    atom.S, ...
                    atom.Si, ...
                    method = obj.NaturalIsotopeCorrectionMethod, ...
                    numTracerCarbon = numTracerCarbon);
                mdv{:, iFragment} = corrected';
            end

        end % correctNaturalIsotopes

        function mdvBiomass = correctBiomass(~, mdv, experimentInfo)

            initialOD = ...
                openmebius.domain.experiment.ExperimentMDVCalculator ...
                .tableScalar(experimentInfo, "ODi");
            finalOD = ...
                openmebius.domain.experiment.ExperimentMDVCalculator ...
                .tableScalar(experimentInfo, "ODf");
            fraction = initialOD / finalOD;

            mdvBiomass = mdv;
            mdvBiomass{:, :} = nan;

            if isnan(fraction)
                return
            end

            correction = MDVCorrection();

            for iFragment = 1:width(mdv)
                fragment = mdv{:, iFragment};
                fragment(isnan(fragment)) = 0;
                mdvBiomass{:, iFragment} = correction.correctBiomass( ...
                    eye(size(fragment)), ...
                    fragment, ...
                    fraction);
            end

        end % correctBiomass

        function [enrichment, errors, warnings] = createEnrichment( ...
                obj, mdv, mdvErrors, msMetaboliteTable)

            if isempty(mdv) || isempty(mdvErrors)
                error( ...
                    "OpenMebius2:ExperimentMDVCalculator:EmptyMDV", ...
                    "The MDV data is empty.");
            end

            validMDV = mdv(:, ~mdvErrors);
            numFragments = width(validMDV);
            errors = false(numFragments, 1);
            warnings = strings(numFragments, 1);
            numWarnings = 0;
            enrichment = array2table( ...
                nan(numFragments, 1), ...
                VariableNames = "Enrichment", ...
                RowNames = validMDV.Properties.VariableNames);

            metaboliteNames = string(msMetaboliteTable.Metabolite);

            for iFragment = 1:numFragments
                fragmentName = string( ...
                    validMDV.Properties.VariableNames{iFragment});
                modelIndex = find(metaboliteNames == fragmentName, 1);

                if isempty(modelIndex)
                    numWarnings = numWarnings + 1;
                    warnings(numWarnings) = ...
                        "The metabolite " + fragmentName + ...
                        " is not found in the model.";
                    errors(iFragment) = true;
                    continue
                end

                numCarbon = ...
                    openmebius.domain.experiment.ExperimentMDVCalculator ...
                    .tableScalar(msMetaboliteTable(modelIndex, :), "Carbon");
                enrichment{fragmentName, "Enrichment"} = ...
                    obj.calculateEnrichment( ...
                    numCarbon, ...
                    validMDV{:, iFragment});
            end

            warnings = warnings(1:numWarnings);

        end % createEnrichment

        function numTracerCarbon = getNumTracerCarbon( ...
                ~, msMetaboliteTable, fragmentName, numMDV)

            numTracerCarbon = max(0, numMDV - 1);
            variables = string( ...
                msMetaboliteTable.Properties.VariableNames);

            if isempty(msMetaboliteTable) || ...
                    ~all(ismember(["Metabolite", "Carbon"], variables))
                return
            end

            index = find( ...
                string(msMetaboliteTable.Metabolite) == fragmentName, ...
                1);

            if isempty(index)
                return
            end

            candidate = ...
                openmebius.domain.experiment.ExperimentMDVCalculator ...
                .tableScalar(msMetaboliteTable(index, :), "Carbon");

            if isempty(candidate) || isnan(candidate)
                return
            end

            numTracerCarbon = candidate;

        end % getNumTracerCarbon

        function enrichment = calculateEnrichment(~, numCarbon, mdv)

            arguments
                ~
                numCarbon (1, 1) double {mustBePositive, mustBeInteger}
                mdv (:, 1) double {mustBeNonnegative, ...
                    mustBeLessThanOrEqual(mdv, 1)}
            end

            enrichment = sum(mdv(1:numCarbon + 1) .* (0:numCarbon)') / ...
                numCarbon;

        end % calculateEnrichment

        function assertExperimentInfo(~, experimentInfo)

            requiredVariables = ["ODi", "ODf"];

            if height(experimentInfo) ~= 1 || ...
                    ~all(ismember( ...
                    requiredVariables, ...
                    string(experimentInfo.Properties.VariableNames)))
                error( ...
                    "OpenMebius2:ExperimentMDVCalculator:" + ...
                    "InvalidExperimentInfo", ...
                    "Experiment information must contain one ODi/ODf row.");
            end

        end % assertExperimentInfo

    end % methods (Access = private)

    methods (Static, Access = private)

        function value = tableScalar(source, variableName)

            value = source.(variableName);

            if iscell(value)
                value = value{1};
            else
                value = value(1);
            end

        end % tableScalar

    end % methods (Static, Access = private)

end % classdef
