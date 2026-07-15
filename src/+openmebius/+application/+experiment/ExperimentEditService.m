classdef ExperimentEditService < handle
    % EXPERIMENTEDITSERVICE
    % Coordinates experiment table updates and persistence outside UI.

    methods

        function result = saveInfo(~, model, experiments, batch, infoTable)

            arguments
                ~
                model
                experiments
                batch
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
                experiments
                batch
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

        function result = copyTracerToAllEntries(~, model, experiments, batch, tracerTable, selection)

            arguments
                ~
                model
                experiments
                batch
                tracerTable table
                selection (:, :) double
            end

            openmebius.application.experiment.ExperimentEditService ...
                .syncModel(model, experiments, batch);

            [selectedRow, selectedColumn] = ...
                openmebius.application.experiment.ExperimentEditService ...
                .selectedTableCell(selection, tracerTable);

            updatedTracerTable = tracerTable;
            selectedTracer = updatedTracerTable{selectedRow, selectedColumn};

            for row = 1:height(updatedTracerTable)
                updatedTracerTable{row, selectedColumn} = selectedTracer;
            end

            openmebius.application.experiment.ExperimentEditService ...
                .updateExperimentData(experiments, updatedTracerTable, "Tracer");

            batch.updateExperimentalData(experiments);

            result = openmebius.application.experiment.ExperimentEditResult( ...
                Experiments = experiments, ...
                Batch = batch, ...
                UpdatedTable = updatedTracerTable, ...
                Messages = "Selected tracer copied to all entries.");

        end % copyTracerToAllEntries

    end % methods

    methods (Static, Access = private)

        function syncModel(model, experiments, batch)

            openmebius.application.experiment.ExperimentEditService ...
                .assertValidObject(experiments, "Experiment data");
            openmebius.application.experiment.ExperimentEditService ...
                .assertValidObject(batch, "Batch data");

            experiments.updateModel(model);
            batch.updateExperimentalData(experiments);

        end % syncModel

        function assertValidObject(value, name)

            if isempty(value) || ...
                    (isa(value, 'handle') && ~isvalid(value))
                error( ...
                    "OpenMebius2:ExperimentEdit:InvalidObject", ...
                    "%s is not valid.", ...
                    name);
            end

        end % assertValidObject

        function updateExperimentData(experiments, data, type)

            try
                report = experiments.updateExpData(data, type);
            catch ME
                error( ...
                    "OpenMebius2:ExperimentEdit:UpdateFailed", ...
                    "Failed to update %s experiment data: %s", ...
                    type, ...
                    string(ME.message));
            end

            if ~report.IsValid
                error( ...
                    "OpenMebius2:ExperimentEdit:UpdateFailed", ...
                    "Failed to update %s experiment data: %s", ...
                    type, ...
                    report.ErrorMessage);
            end

        end % updateExperimentData

        function [row, column] = selectedTableCell(selection, tableData)

            if isempty(selection) || size(selection, 2) < 2
                error( ...
                    "OpenMebius2:ExperimentEdit:InvalidSelection", ...
                    "A tracer table cell must be selected.");
            end

            row = selection(1, 1);
            column = selection(1, 2);

            if row < 1 || row > height(tableData) || ...
                    column < 1 || column > width(tableData)
                error( ...
                    "OpenMebius2:ExperimentEdit:SelectionOutOfRange", ...
                    "The selected tracer table cell is outside the table.");
            end

        end % selectedTableCell

        function saveExperiments(experiments)

            try
                report = experiments.saveExpData();
            catch ME
                error( ...
                    "OpenMebius2:ExperimentEdit:SaveFailed", ...
                    "Failed to save experiment data: %s", ...
                    string(ME.message));
            end

            if ~report.IsValid
                error( ...
                    "OpenMebius2:ExperimentEdit:SaveFailed", ...
                    "%s", ...
                    report.ErrorMessage);
            end

        end % saveExperiments

    end % methods (Static, Access = private)

end % classdef
