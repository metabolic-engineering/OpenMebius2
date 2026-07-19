classdef ExperimentImportController < handle
    % EXPERIMENTIMPORTCONTROLLER Runs experiment import use cases.

    properties (Access = private)
        ExperimentImportService
        RawMSImportService
    end

    methods

        function obj = ExperimentImportController(options)

            arguments
                options.ExperimentImportService = []
                options.RawMSImportService = []
            end

            experimentImportService = options.ExperimentImportService;

            if isempty(experimentImportService)
                experimentImportService = openmebius.application.experiment ...
                    .ExperimentImportService();
            end

            rawMSImportService = options.RawMSImportService;

            if isempty(rawMSImportService)
                rawMSImportService = openmebius.application.experiment ...
                    .RawMSImportService( ...
                        ExperimentImportService = experimentImportService);
            end

            obj.ExperimentImportService = experimentImportService;
            obj.RawMSImportService = rawMSImportService;

        end % constructor

        function outcome = importFiles( ...
                obj, experimentLocation, files, model)

            arguments
                obj
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                files (:, 1) string
                model
            end

            outcome = obj.execute( ...
                @() obj.ExperimentImportService.importFiles( ...
                    experimentLocation, files, model));

        end % importFiles

        function outcome = reload(obj, experimentLocation, model)

            arguments
                obj
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                model
            end

            outcome = obj.execute( ...
                @() obj.ExperimentImportService.reload( ...
                    experimentLocation, model));

        end % reload

        function outcome = importShimadzuASCII( ...
                obj, rawInput, experimentLocation, model)

            arguments
                obj
                rawInput
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                model
            end

            outcome = obj.execute( ...
                @() obj.RawMSImportService.importShimadzuASCII( ...
                    rawInput, experimentLocation, model));

        end % importShimadzuASCII

    end % methods

    methods (Access = private)

        function outcome = execute(~, command)

            try
                result = command();
                outcome = openmebius.application.experiment ...
                    .ExperimentImportOutcome( ...
                        true, Result = result);
            catch exception
                outcome = openmebius.application.experiment ...
                    .ExperimentImportOutcome( ...
                        false, ...
                        ErrorMessage = string(exception.message), ...
                        Exception = exception);
            end

        end % execute

    end % methods (Access = private)

end % classdef
