classdef ExperimentImportService < handle
    % EXPERIMENTIMPORTSERVICE
    % Coordinates experiment import/reload without touching App Designer UI.

    properties (Access = private)
        ExperimentRepository
        ExperimentLoadRepository
        BatchRepository
    end

    methods

        function obj = ExperimentImportService(options)

            arguments
                options.ExperimentRepository = ...
                    openmebius.infrastructure.experiment.ExperimentRepository()
                options.ExperimentLoadRepository = ...
                    openmebius.infrastructure.experiment.ExperimentRepository()
                options.BatchRepository = ...
                    openmebius.infrastructure.batch.BatchRepository()
            end

            obj.ExperimentRepository = options.ExperimentRepository;
            obj.ExperimentLoadRepository = options.ExperimentLoadRepository;
            obj.BatchRepository = options.BatchRepository;

        end % constructor

        function result = importFiles(obj, experimentLocation, files, model)

            arguments
                obj
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                files (:, 1) string
                model
            end

            copyReport = obj.ExperimentRepository.importFiles( ...
                experimentLocation, ...
                files);

            result = obj.reload( ...
                experimentLocation, ...
                model, ...
                Messages = copyReport.Messages, ...
                ImportedFiles = copyReport.ImportedFiles, ...
                SkippedFiles = copyReport.SkippedFiles);

        end % importFiles

        function result = reload(obj, experimentLocation, model, options)

            arguments
                obj
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                model
                options.Messages (:, 1) string = strings(0, 1)
                options.ImportedFiles (:, 1) string = strings(0, 1)
                options.SkippedFiles (:, 1) string = strings(0, 1)
            end

            experiments = obj.ExperimentLoadRepository.load( ...
                experimentLocation, ...
                model);

            batch = obj.BatchRepository.load( ...
                experimentLocation, ...
                experiments);

            messages = [
                        options.Messages
                        "Experimental data loaded successfully."
                        "Batch object created successfully."
                        ];

            result = openmebius.application.experiment.ExperimentImportResult( ...
                Experiments = experiments, ...
                Batch = batch, ...
                Messages = messages, ...
                ImportedFiles = options.ImportedFiles, ...
                SkippedFiles = options.SkippedFiles);

        end % reload

    end % methods

end % classdef
