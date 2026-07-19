classdef ProjectArtifactRepository
    % PROJECTARTIFACTREPOSITORY Restores runtime artifacts from repositories.

    properties (Access = private)
        ModelRepository
        ExperimentRepository
        BatchRepository
        ResultRepository
    end

    methods

        function obj = ProjectArtifactRepository(options)

            arguments
                options.ModelRepository = ...
                    openmebius.infrastructure.model.ModelRepository()
                options.ExperimentRepository = ...
                    openmebius.infrastructure.experiment.ExperimentRepository()
                options.BatchRepository = ...
                    openmebius.infrastructure.batch.BatchRepository()
                options.ResultRepository = ...
                    openmebius.infrastructure.result.ResultRepository()
            end

            obj.ModelRepository = options.ModelRepository;
            obj.ExperimentRepository = options.ExperimentRepository;
            obj.BatchRepository = options.BatchRepository;
            obj.ResultRepository = options.ResultRepository;

        end

        function artifacts = load(obj, session, options)

            arguments
                obj
                session (1, 1) openmebius.domain.project.ProjectSession
                options.AllowEmptyExperiments (1, 1) logical = false
            end

            paths = session.Paths;
            model = obj.ModelRepository.load(paths.modelLocation());

            if options.AllowEmptyExperiments
                experiments = obj.ExperimentRepository.initialize( ...
                    paths.experimentLocation(), model);
            else
                experiments = obj.ExperimentRepository.load( ...
                    paths.experimentLocation(), model);
            end

            batch = obj.BatchRepository.load( ...
                paths.experimentLocation(), experiments);
            result = obj.ResultRepository.open(paths.resultLocation());
            messages = [ ...
                "Model loaded successfully."
                "Experiment data loaded successfully."
                "Batch session created successfully."
                "Result session created successfully."];
            artifacts = openmebius.application.project.ProjectArtifacts( ...
                Model = model, ...
                Experiments = experiments, ...
                Batch = batch, ...
                Result = result, ...
                Messages = messages);

        end

    end

end
