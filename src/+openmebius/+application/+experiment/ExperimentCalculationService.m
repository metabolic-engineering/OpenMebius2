classdef ExperimentCalculationService < handle
    % EXPERIMENTCALCULATIONSERVICE
    % Coordinates experiment table updates and MDV calculation outside UI.

    methods

        function result = calculateMDV(~, model, experiments, batch, infoTable, uptakeTable, tracerTable)

            arguments
                ~
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

            experiments.calculateMDV();

            if experiments.isError
                error( ...
                    "OpenMebius2:ExperimentCalculation:CalculationFailed", ...
                    "%s", ...
                    openmebius.application.experiment.ExperimentCalculationService ...
                    .statusMessage(experiments, "MDV calculation failed."));
            end

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
                HasCalculatedMDV = hasCalculatedMDV);

        end % calculateMDV

    end % methods

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
                isUpdateError = experiments.updateExpData(data, type);
            catch ME
                error( ...
                    "OpenMebius2:ExperimentCalculation:UpdateFailed", ...
                    "Failed to update %s experiment data: %s", ...
                    type, ...
                    string(ME.message));
            end

            if isUpdateError
                error( ...
                    "OpenMebius2:ExperimentCalculation:UpdateFailed", ...
                    "Failed to update %s experiment data: %s", ...
                    type, ...
                    openmebius.application.experiment.ExperimentCalculationService ...
                    .statusMessage(experiments, "Unknown update error."));
            end

        end % updateExperimentData

        function message = statusMessage(experiments, fallback)

            message = string(fallback);

            try
                statusMessage = string(experiments.statusMsg);

                if ~isempty(statusMessage)
                    statusMessage = statusMessage(strlength(statusMessage) > 0);
                end

                if ~isempty(statusMessage)
                    message = strjoin(statusMessage(:), newline);
                end
            catch
            end

        end % statusMessage

    end % methods (Static, Access = private)

end % classdef
