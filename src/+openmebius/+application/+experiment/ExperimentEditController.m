classdef ExperimentEditController < handle
    % EXPERIMENTEDITCONTROLLER Runs experiment editing use cases.

    properties (Access = private)
        Service
        TracerConfigurationService
    end

    methods

        function obj = ExperimentEditController(options)

            arguments
                options.Service = openmebius.application.experiment ...
                    .ExperimentEditService()
                options.TracerConfigurationService = ...
                    openmebius.application.experiment ...
                        .TracerConfigurationService()
            end

            obj.Service = options.Service;
            obj.TracerConfigurationService = ...
                options.TracerConfigurationService;

        end % constructor

        function outcome = saveInfo( ...
                obj, model, experiments, batch, infoTable)

            arguments
                obj
                model
                experiments
                batch
                infoTable table
            end

            outcome = obj.execute( ...
                @() obj.Service.saveInfo( ...
                    model, experiments, batch, infoTable));

        end % saveInfo

        function outcome = saveTracer( ...
                obj, model, experiments, batch, ...
                uptakeTable, tracerTable)

            arguments
                obj
                model
                experiments
                batch
                uptakeTable table
                tracerTable table
            end

            outcome = obj.execute( ...
                @() obj.Service.saveTracer( ...
                    model, experiments, batch, ...
                    uptakeTable, tracerTable));

        end % saveTracer

        function outcome = copyTracerToAllEntries( ...
                obj, model, experiments, batch, tracerTable, selection)

            arguments
                obj
                model
                experiments
                batch
                tracerTable table
                selection (:, :) double
            end

            outcome = obj.execute( ...
                @() obj.Service.copyTracerToAllEntries( ...
                    model, experiments, batch, ...
                    tracerTable, selection));

        end % copyTracerToAllEntries

        function outcome = loadTracerConfiguration( ...
                obj, experiments, position)

            arguments
                obj
                experiments
                position (1, 2) double
            end

            outcome = obj.execute( ...
                @() obj.TracerConfigurationService.load( ...
                    experiments, position));

        end % loadTracerConfiguration

        function outcome = prepareTracerConfiguration( ...
                obj, experiments, currentTracerTable, position)

            arguments
                obj
                experiments
                currentTracerTable table
                position (1, 2) double
            end

            outcome = obj.execute( ...
                @() obj.TracerConfigurationService.prepare( ...
                    experiments, currentTracerTable, position));

        end % prepareTracerConfiguration

        function outcome = applyTracerConfiguration( ...
                obj, position, editorTable)

            arguments
                obj
                position (1, 2) double
                editorTable table
            end

            outcome = obj.execute( ...
                @() obj.TracerConfigurationService.apply( ...
                    position, editorTable));

        end % applyTracerConfiguration

    end % methods

    methods (Access = private)

        function outcome = execute(~, command)

            try
                result = command();
                outcome = openmebius.application.experiment ...
                    .ExperimentEditOutcome( ...
                        true, Result = result);
            catch exception
                outcome = openmebius.application.experiment ...
                    .ExperimentEditOutcome( ...
                        false, ...
                        ErrorMessage = string(exception.message), ...
                        Exception = exception);
            end

        end % execute

    end % methods (Access = private)

end % classdef
