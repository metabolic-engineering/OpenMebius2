classdef ExperimentEditService < handle
    % EXPERIMENTEDITSERVICE
    % Coordinates experiment table updates and persistence outside UI.

    methods

        function result = saveInfo(~, model, experiments, batch, infoTable)

            arguments
                ~
                model
                experiments IOExps
                batch Batch
                infoTable table
            end

            openmebius.application.experiment.ExperimentEditService ...
                .syncModel(model, experiments, batch);

            openmebius.application.experiment.ExperimentEditService ...
                .updateExperimentData(experiments, infoTable, "Info");
            openmebius.application.experiment.ExperimentEditService ...
                .saveExperiments(experiments);

            batch.updateExperimentalData(experiments);

            result = openmebius.application.experiment.ExperimentEditResult( ...
                Experiments = experiments, ...
                Batch = batch, ...
                Messages = [
                            "Experimental data updated."
                            "Experimental data saved successfully."
                           ]);

        end % saveInfo

        function result = saveTracer(~, model, experiments, batch, uptakeTable, tracerTable)

            arguments
                ~
                model
                experiments IOExps
                batch Batch
                uptakeTable table
                tracerTable table
            end

            openmebius.application.experiment.ExperimentEditService ...
                .syncModel(model, experiments, batch);

            openmebius.application.experiment.ExperimentEditService ...
                .updateExperimentData(experiments, uptakeTable, "Uptake");
            openmebius.application.experiment.ExperimentEditService ...
                .updateExperimentData(experiments, tracerTable, "Tracer");
            openmebius.application.experiment.ExperimentEditService ...
                .saveExperiments(experiments);

            batch.updateExperimentalData(experiments);

            result = openmebius.application.experiment.ExperimentEditResult( ...
                Experiments = experiments, ...
                Batch = batch, ...
                Messages = [
                            "Uptake table updated."
                            "Tracer table updated."
                            "Experimental data saved successfully."
                           ]);

        end % saveTracer

    end % methods

    methods (Static, Access = private)

        function syncModel(model, experiments, batch)

            openmebius.application.experiment.ExperimentEditService ...
                .assertValidHandle(experiments, "Experiment data");
            openmebius.application.experiment.ExperimentEditService ...
                .assertValidHandle(batch, "Batch data");

            experiments.updateModel(model);
            batch.updateExperimentalData(experiments);

        end % syncModel

        function assertValidHandle(value, name)

            if isempty(value) || ~isvalid(value)
                error( ...
                    "OpenMebius2:ExperimentEdit:InvalidObject", ...
                    "%s is not valid.", ...
                    name);
            end

        end % assertValidHandle

        function updateExperimentData(experiments, data, type)

            try
                isUpdateError = experiments.updateExpData(data, type);
            catch ME
                error( ...
                    "OpenMebius2:ExperimentEdit:UpdateFailed", ...
                    "Failed to update %s experiment data: %s", ...
                    type, ...
                    string(ME.message));
            end

            if isUpdateError
                error( ...
                    "OpenMebius2:ExperimentEdit:UpdateFailed", ...
                    "Failed to update %s experiment data: %s", ...
                    type, ...
                    openmebius.application.experiment.ExperimentEditService ...
                    .statusMessage(experiments, "Unknown update error."));
            end

        end % updateExperimentData

        function saveExperiments(experiments)

            try
                isSaveError = experiments.saveExpData();
            catch ME
                error( ...
                    "OpenMebius2:ExperimentEdit:SaveFailed", ...
                    "Failed to save experiment data: %s", ...
                    string(ME.message));
            end

            if isSaveError
                error( ...
                    "OpenMebius2:ExperimentEdit:SaveFailed", ...
                    "%s", ...
                    openmebius.application.experiment.ExperimentEditService ...
                    .statusMessage(experiments, "Experiment save failed."));
            end

        end % saveExperiments

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
