classdef ExperimentCalculationController < handle
    % EXPERIMENTCALCULATIONCONTROLLER Runs the MDV calculation use case.

    properties (Access = private)
        Service
    end

    methods

        function obj = ExperimentCalculationController(options)

            arguments
                options.Service = openmebius.application.experiment ...
                    .ExperimentCalculationService()
            end

            obj.Service = options.Service;

        end % constructor

        function outcome = calculate( ...
                obj, model, experiments, batch, ...
                infoTable, uptakeTable, tracerTable)

            arguments
                obj
                model
                experiments
                batch
                infoTable table
                uptakeTable table
                tracerTable table
            end

            try
                result = obj.Service.calculateMDV( ...
                    model, ...
                    experiments, ...
                    batch, ...
                    infoTable, ...
                    uptakeTable, ...
                    tracerTable);
                outcome = openmebius.application.experiment ...
                    .ExperimentCalculationOutcome( ...
                        "finished", Result = result);
            catch exception
                outcome = openmebius.application.experiment ...
                    .ExperimentCalculationOutcome( ...
                        "error", ...
                        ErrorMessage = string(exception.message), ...
                        Exception = exception);
            end

        end % calculate

    end % methods

end % classdef
