classdef TracerConfigurationService < handle
    % TRACERCONFIGURATIONSERVICE Prepares and applies tracer editor data.

    methods

        function decision = prepare( ...
                obj, experiments, currentTracerTable, position)

            arguments
                obj
                experiments
                currentTracerTable table
                position (1, 2) double {mustBeInteger, mustBePositive}
            end

            openmebius.application.experiment ...
                .TracerConfigurationService ...
                .assertExperimentWorkspace(experiments);

            if ~ismethod(experiments, "getTracerTable")
                error( ...
                    "OpenMebius2:TracerConfiguration:" + ...
                    "UnsupportedExperiments", ...
                    "Experiment data must provide getTracerTable.");
            end

            storedTracerTable = experiments.getTracerTable();

            if ~isequaln(storedTracerTable, currentTracerTable)
                decision = openmebius.application.experiment ...
                    .TracerConfigurationLaunchDecision( ...
                        Position = position, ...
                        Message = ...
                            "Label table has been modified. " + ...
                            "Please save the table before editing.");
                return
            end

            result = obj.load(experiments, position);
            decision = openmebius.application.experiment ...
                .TracerConfigurationLaunchDecision( ...
                    IsAllowed = true, ...
                    Position = result.Position, ...
                    EditorTable = result.EditorTable);

        end % prepare

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
