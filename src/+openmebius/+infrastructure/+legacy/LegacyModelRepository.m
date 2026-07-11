classdef LegacyModelRepository < handle
    % LEGACYMODELREPOSITORY
    % Loads the existing EMUModel object from a model location.

    methods

        function model = load(~, modelLocation)

            arguments
                ~
                modelLocation openmebius.domain.model.ModelLocation
            end

            model = EMUModel(modelLocation);

            if isempty(model) || ~isvalid(model)
                error( ...
                    "OpenMebius2:LegacyProject:InvalidModelObject", ...
                    "Failed to create EMUModel.");
            end

            if model.isError
                error( ...
                    "OpenMebius2:LegacyProject:ModelLoadFailed", ...
                    "%s", string(model.statusMsg));
            end

            ioStatus = model.getIOStatus();

            if ~strcmp(ioStatus, "completed")
                error( ...
                    "OpenMebius2:LegacyProject:ModelIncomplete", ...
                    "%s", string(model.statusMsg));
            end

        end % load

    end % methods

end % classdef
