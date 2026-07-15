classdef ExperimentCalculationService < handle
    % EXPERIMENTCALCULATIONSERVICE
    % Coordinates experiment table updates and MDV calculation outside UI.

    properties (Access = private)
        MDVCalculator
        MessagePublisher
    end

    methods

        function obj = ExperimentCalculationService(options)

            arguments
                options.MDVCalculator = openmebius.domain.experiment ...
                    .ExperimentMDVCalculator()
                options.MessagePublisher = openmebius.presentation ...
                    .notification.GeneralMessagePublisher()
            end

            obj.MDVCalculator = options.MDVCalculator;
            obj.MessagePublisher = options.MessagePublisher;

        end % constructor

        function result = calculateMDV(obj, model, experiments, batch, infoTable, uptakeTable, tracerTable)

            arguments
                obj
                model
                experiments
                batch
                infoTable table
                uptakeTable table
                tracerTable table
            end

            openmebius.application.experiment.ExperimentCalculationService ...
                .assertValidObject(experiments, "Experiment data");
            openmebius.application.experiment.ExperimentCalculationService ...
                .assertValidObject(batch, "Batch data");

            experiments.updateModel(model);
            batch.updateExperimentalData(experiments);

            openmebius.application.experiment.ExperimentCalculationService ...
                .updateExperimentData(experiments, infoTable, "Info");
            openmebius.application.experiment.ExperimentCalculationService ...
                .updateExperimentData(experiments, uptakeTable, "Uptake");
            openmebius.application.experiment.ExperimentCalculationService ...
                .updateExperimentData(experiments, tracerTable, "Tracer");

            warnings = obj.calculateDerivedData(experiments);

            batch.updateExperimentalData(experiments);

            hasCalculatedMDV = experiments.hasCalculatedMDV();

            if ~hasCalculatedMDV
                error( ...
                    "OpenMebius2:ExperimentCalculation:NotCalculated", ...
                    "MDV-derived tables were not created.");
            end

            result = openmebius.application.experiment.ExperimentCalculationResult( ...
                Experiments = experiments, ...
                Batch = batch, ...
                Messages = [
                            "Experiment tables updated successfully."
                            "MDV-derived tables have been updated successfully."
                           ], ...
                Warnings = warnings, ...
                HasCalculatedMDV = hasCalculatedMDV);

        end % calculateMDV

    end % methods

    methods (Access = private)

        function warnings = calculateDerivedData(obj, experiments)

            experimentNames = string(experiments.getExpList());
            experimentNames = experimentNames(:);
            numExperiments = numel(experimentNames);

            if numExperiments == 0
                error( ...
                    "OpenMebius2:ExperimentCalculation:CalculationFailed", ...
                    "No experiments are available for MDV calculation.");
            end

            derivedData = cell(numExperiments, 1);
            warningGroups = repmat({strings(0, 1)}, numExperiments, 1);
            errors = strings(numExperiments, 1);
            numErrors = 0;

            for iExperiment = 1:numExperiments
                experimentName = experimentNames(iExperiment);

                try
                    input = experiments.getMDVCalculationInput( ...
                        experimentName);
                    derivedData{iExperiment} = ...
                        obj.MDVCalculator.calculate(input);
                    warningGroups{iExperiment} = ...
                        derivedData{iExperiment}.Warnings;
                catch ME
                    numErrors = numErrors + 1;
                    errors(numErrors) = ...
                        "Failed to calculate MDV-derived data for " + ...
                        experimentName + ": " + string(ME.message);
                end
            end

            if numErrors > 0
                error( ...
                    "OpenMebius2:ExperimentCalculation:CalculationFailed", ...
                    "%s", ...
                    join(errors(1:numErrors), newline));
            end

            for iExperiment = 1:numExperiments
                experiments.applyMDVDerivedData( ...
                    experimentNames(iExperiment), ...
                    derivedData{iExperiment});
            end

            warnings = unique(vertcat(warningGroups{:}), "stable");

            for iWarning = 1:numel(warnings)
                obj.MessagePublisher.write("warning", warnings(iWarning));
            end

            obj.MessagePublisher.write( ...
                "info", ...
                "MDV calculation completed.");

        end % calculateDerivedData

    end % methods (Access = private)

    methods (Static, Access = private)

        function assertValidObject(value, name)

            if isempty(value) || ...
                    (isa(value, 'handle') && ~isvalid(value))
                error( ...
                    "OpenMebius2:ExperimentCalculation:InvalidObject", ...
                    "%s is not valid.", ...
                    name);
            end

        end % assertValidObject

        function updateExperimentData(experiments, data, type)

            try
                report = experiments.updateExpData(data, type);
            catch ME
                error( ...
                    "OpenMebius2:ExperimentCalculation:UpdateFailed", ...
                    "Failed to update %s experiment data: %s", ...
                    type, ...
                    string(ME.message));
            end

            if ~report.IsValid
                error( ...
                    "OpenMebius2:ExperimentCalculation:UpdateFailed", ...
                    "Failed to update %s experiment data: %s", ...
                    type, ...
                    report.ErrorMessage);
            end

        end % updateExperimentData

    end % methods (Static, Access = private)

end % classdef
