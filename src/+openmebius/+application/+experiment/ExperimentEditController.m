classdef ExperimentEditController < handle
    % EXPERIMENTEDITCONTROLLER Runs experiment editing use cases.

    properties (Access = private)
        Service
    end

    methods

        function obj = ExperimentEditController(options)

            arguments
                options.Service = openmebius.application.experiment ...
                    .ExperimentEditService()
            end

            obj.Service = options.Service;

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

    end % methods

    methods (Access = private)

        function outcome = execute(~, command)

            try
                result = command();
                outcome = openmebius.application.experiment ...
                    .ExperimentEditOutcome( ...
                        "finished", Result = result);
            catch exception
                outcome = openmebius.application.experiment ...
                    .ExperimentEditOutcome( ...
                        "error", ...
                        ErrorMessage = string(exception.message), ...
                        Exception = exception);
            end

        end % execute

    end % methods (Access = private)

end % classdef
