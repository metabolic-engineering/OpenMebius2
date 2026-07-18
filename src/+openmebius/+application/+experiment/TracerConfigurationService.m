classdef TracerConfigurationService < handle
    % TRACERCONFIGURATIONSERVICE Prepares and applies tracer editor data.

    methods

        function result = load(~, experiments, position)

            arguments
                ~
                experiments
                position (1, 2) double {mustBeInteger, mustBePositive}
            end

            openmebius.application.experiment.TracerConfigurationService ...
                .assertExperimentWorkspace(experiments);
            editorTable = experiments.createTableTracerConfig(position);
            result = openmebius.application.experiment ...
                .TracerConfigurationResult( ...
                    Position = position, ...
                    EditorTable = editorTable);

        end % load

        function result = apply(~, position, editorTable)

            arguments
                ~
                position (1, 2) double {mustBeInteger, mustBePositive}
                editorTable table
            end

            pattern = openmebius.domain.experiment ...
                .TracerPatternCodec.encode(editorTable);
            result = openmebius.application.experiment ...
                .TracerConfigurationResult( ...
                    Position = position, ...
                    EditorTable = editorTable, ...
                    Pattern = pattern);

        end % apply

    end % methods

    methods (Static, Access = private)

        function assertExperimentWorkspace(experiments)

            if isempty(experiments) || ...
                    (isa(experiments, "handle") && ~isvalid(experiments))
                error( ...
                    "OpenMebius2:TracerConfiguration:InvalidExperiments", ...
                    "Experiment data is not valid.");
            end

            if ~ismethod(experiments, "createTableTracerConfig")
                error( ...
                    "OpenMebius2:TracerConfiguration:UnsupportedExperiments", ...
                    "Experiment data must provide " + ...
                    "createTableTracerConfig.");
            end

        end % assertExperimentWorkspace

    end % methods (Static, Access = private)

end % classdef
