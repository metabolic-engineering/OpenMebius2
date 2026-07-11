classdef LegacyBatchRepository < handle
    % LEGACYBATCHREPOSITORY
    % Loads the existing Batch object for an experiment set.

    methods

        function batch = load(~, experimentLocation, experiments)

            arguments
                ~
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                experiments
            end

            if ismethod(experiments, 'getExperimentLocation')
                loadedLocation = experiments.getExperimentLocation();

                if loadedLocation.Directory ~= experimentLocation.Directory
                    error( ...
                        "OpenMebius2:LegacyProject:ExperimentLocationMismatch", ...
                        "Batch and experiment locations do not match.");
                end
            end

            batch = Batch(experiments);

            if isempty(batch) || ~isvalid(batch)
                error( ...
                    "OpenMebius2:LegacyProject:InvalidBatchObject", ...
                    "Failed to create Batch.");
            end

        end % load

    end % methods

end % classdef
