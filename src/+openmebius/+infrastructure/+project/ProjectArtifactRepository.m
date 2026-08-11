classdef ProjectArtifactRepository
    % PROJECTARTIFACTREPOSITORY Restores runtime artifacts from repositories.

    properties (Access = private)
        ModelRepository
        ExperimentRepository
        BatchRepository
        ResultRepository
        ResultBatchRecoveryService
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
                options.ResultBatchRecoveryService = ...
                    openmebius.application.result ...
                    .ResultBatchRecoveryService()
            end

            obj.ModelRepository = options.ModelRepository;
            obj.ExperimentRepository = options.ExperimentRepository;
            obj.BatchRepository = options.BatchRepository;
            obj.ResultRepository = options.ResultRepository;
            obj.ResultBatchRecoveryService = ...
                options.ResultBatchRecoveryService;

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
            recoveredIds = obj.ResultBatchRecoveryService.recover( ...
                batch, result);
            messages = [ ...
                            "Model loaded successfully."
                        "Experiment data loaded successfully."
                        "Batch session created successfully."
                        "Result session created successfully."];

            if ~isempty(recoveredIds)
                messages(end + 1, 1) = sprintf( ...
                    "%d batch entries restored from result files.", ...
                    numel(recoveredIds));
            end

            artifacts = openmebius.application.project.ProjectArtifacts( ...
                Model = model, ...
                Experiments = experiments, ...
                Batch = batch, ...
                Result = result, ...
                Messages = messages);

        end

    end

end
