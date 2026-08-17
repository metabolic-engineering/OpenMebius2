classdef BatchRepository
    % BATCHREPOSITORY Restores the application batch session.

    properties (Access = private)
        NotificationPublisher (1, 1) function_handle = @(~) []
    end

    methods

        function obj = BatchRepository(options)

            arguments
                options.NotificationPublisher (1, 1) function_handle = @(~) []
            end

            obj.NotificationPublisher = options.NotificationPublisher;

        end

        function batch = load(obj, experimentLocation, experiments)

            arguments
                obj
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

            batch = openmebius.application.batch.BatchSession( ...
                experiments, ...
                NotificationEmitter = openmebius.application.notification ...
                .NotificationEmitter( ...
                Publisher = obj.NotificationPublisher, ...
                Source = "BatchSession"));

            if isempty(batch) || ~isvalid(batch)
                error( ...
                    "OpenMebius2:BatchRepository:InvalidSession", ...
                    "Failed to create the batch session.");
            end

        end

    end

end
