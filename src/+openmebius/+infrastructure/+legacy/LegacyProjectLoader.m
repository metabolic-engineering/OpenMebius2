classdef LegacyProjectLoader < handle
    % LEGACYPROJECTLOADER
    % Creates and validates legacy project objects without touching UI.
    %
    % This class must not access App Designer components.

    methods

        function artifacts = load(~, session)

            arguments
                ~
                session openmebius.domain.project.ProjectSession
            end

            messages = strings(0, 1);
            paths = session.Paths;

            % -------------------------------------------------------------
            % Model
            % -------------------------------------------------------------
            model = EMUModel(paths.ModelDirectory);

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

            messages(end + 1, 1) = "Model loaded successfully.";

            % -------------------------------------------------------------
            % Experiments
            % -------------------------------------------------------------
            experiments = IOExps( ...
                paths.ExperimentDirectory, ...
                paths.ModelDirectory);

            if isempty(experiments) || ~isvalid(experiments)
                error( ...
                    "OpenMebius2:LegacyProject:InvalidExperimentObject", ...
                "Failed to create IOExps.");
            end

            if experiments.isError
                error( ...
                    "OpenMebius2:LegacyProject:ExperimentLoadFailed", ...
                    "%s", string(experiments.statusMsg));
            end

            messages(end + 1, 1) = "Experiment data loaded successfully.";

            % -------------------------------------------------------------
            % Batch
            % -------------------------------------------------------------
            batch = Batch(experiments);

            if isempty(batch) || ~isvalid(batch)
                error( ...
                    "OpenMebius2:LegacyProject:InvalidBatchObject", ...
                "Failed to create Batch.");
            end

            messages(end + 1, 1) = "Batch object created successfully.";

            % -------------------------------------------------------------
            % Result
            % -------------------------------------------------------------
            result = IOResult(paths.ResultDirectory);

            if isempty(result) || ~isvalid(result)
                error( ...
                    "OpenMebius2:LegacyProject:InvalidResultObject", ...
                "Failed to create IOResult.");
            end

            if result.isError
                error( ...
                    "OpenMebius2:LegacyProject:ResultLoadFailed", ...
                    "%s", string(result.statusMsg));
            end

            messages(end + 1, 1) = "Result object created successfully.";

            artifacts = ...
                openmebius.infrastructure.legacy.LegacyProjectArtifacts( ...
                Model = model, ...
                Experiments = experiments, ...
                Batch = batch, ...
                Result = result, ...
                Messages = messages);

        end

    end

end
