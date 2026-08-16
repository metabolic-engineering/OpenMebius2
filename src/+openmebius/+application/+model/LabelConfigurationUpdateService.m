classdef LabelConfigurationUpdateService < handle
    % LABELCONFIGURATIONUPDATESERVICE Applies label settings to a session.

    methods

        function result = apply(~, model, experiments, batch, ...
                labelTable, ratioTables)

            arguments
                ~
                model
                experiments
                batch
                labelTable table
                ratioTables struct
            end

            openmebius.application.model.LabelConfigurationUpdateService ...
                .assertValidObject(model, "Model");
            openmebius.application.model.LabelConfigurationUpdateService ...
                .assertValidObject(experiments, "Experiment data");
            openmebius.application.model.LabelConfigurationUpdateService ...
                .assertValidObject(batch, "Batch data");

            model.updateLabelConfiguration(labelTable, ratioTables);
            experiments.updateModel(model);
            batch.updateExperimentalData(experiments);

            result = openmebius.application.model ...
                .LabelConfigurationUpdateResult( ...
                Messages = ...
                "Label configuration applied successfully.");

        end % apply

    end % methods

    methods (Static, Access = private)

        function assertValidObject(value, name)

            if isempty(value) || ...
                    (isa(value, "handle") && ~isvalid(value))
                error( ...
                    "OpenMebius2:LabelConfiguration:InvalidObject", ...
                    "%s is not valid.", ...
                    name);
            end

        end % assertValidObject

    end % methods (Static, Access = private)

end % classdef
