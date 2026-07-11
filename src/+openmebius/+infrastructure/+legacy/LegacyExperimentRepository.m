classdef LegacyExperimentRepository < handle
    % LEGACYEXPERIMENTREPOSITORY
    % Loads the existing IOExps object from an experiment location.

    methods

        function experiments = load(~, experimentLocation, model)

            arguments
                ~
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                model
            end

            experiments = IOExps(experimentLocation, model);

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

        end % load

    end % methods

end % classdef
