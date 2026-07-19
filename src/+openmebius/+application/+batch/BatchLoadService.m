classdef BatchLoadService < handle
    % BATCHLOADSERVICE
    % Coordinates Batch object loading without touching App Designer UI.

    properties (Access = private)
        BatchRepository
    end

    methods

        function obj = BatchLoadService(options)

            arguments
                options.BatchRepository = ...
                    openmebius.infrastructure.batch.BatchRepository()
            end

            obj.BatchRepository = options.BatchRepository;

        end % constructor

        function result = loadForExperiment(obj, experimentLocation, experiments)

            arguments
                obj
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                experiments
            end

            batch = obj.BatchRepository.load( ...
                experimentLocation, ...
                experiments);

            result = openmebius.application.batch.BatchLoadResult( ...
                Batch = batch, ...
                Messages = "Batch object created successfully.");

        end % loadForExperiment

    end % methods

end % classdef
