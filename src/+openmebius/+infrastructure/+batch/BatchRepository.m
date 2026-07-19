classdef BatchRepository
    % BATCHREPOSITORY Restores the application batch session.

    methods

        function batch = load(~, experimentLocation, experiments)

            arguments
                ~
                experimentLocation openmebius.domain.experiment ...
                    .ExperimentLocation
                experiments
            end

            if ismethod(experiments, 'getExperimentLocation')
                loadedLocation = experiments.getExperimentLocation();

                if loadedLocation.Directory ~= experimentLocation.Directory
                    error( ...
                        "OpenMebius2:BatchRepository:" + ...
                        "ExperimentLocationMismatch", ...
                        "Batch and experiment locations do not match.");
                end
            end

            batch = openmebius.application.batch.BatchSession(experiments);

            if isempty(batch) || ~isvalid(batch)
                error( ...
                    "OpenMebius2:BatchRepository:InvalidSession", ...
                    "Failed to create the batch session.");
            end

        end

    end

end
