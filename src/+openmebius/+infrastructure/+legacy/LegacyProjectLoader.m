classdef LegacyProjectLoader < handle
    % LEGACYPROJECTLOADER
    % Creates and validates legacy project objects without touching UI.
    %
    % This class must not access App Designer components.

    properties (Access = private)
        ModelRepository
        ExperimentRepository
        BatchRepository
        ResultRepository
    end

    methods

        function obj = LegacyProjectLoader(options)

            arguments
                options.ModelRepository = ...
                    openmebius.infrastructure.model.ModelRepository()
                options.ExperimentRepository = ...
                    openmebius.infrastructure.legacy.LegacyExperimentRepository()
                options.BatchRepository = ...
                    openmebius.infrastructure.legacy.LegacyBatchRepository()
                options.ResultRepository = ...
                    openmebius.infrastructure.legacy.LegacyResultRepository()
            end

            obj.ModelRepository = options.ModelRepository;
            obj.ExperimentRepository = options.ExperimentRepository;
            obj.BatchRepository = options.BatchRepository;
            obj.ResultRepository = options.ResultRepository;

        end % constructor

        function artifacts = load(obj, session)

            arguments
                obj
                session openmebius.domain.project.ProjectSession
            end

            messages = strings(0, 1);
            paths = session.Paths;

            % -------------------------------------------------------------
            % Model
            % -------------------------------------------------------------
            model = obj.ModelRepository.load(paths.modelLocation());
            messages(end + 1, 1) = "Model loaded successfully.";

            % -------------------------------------------------------------
            % Experiments
            % -------------------------------------------------------------
            experiments = obj.ExperimentRepository.load( ...
                paths.experimentLocation(), ...
                model);
            messages(end + 1, 1) = "Experiment data loaded successfully.";

            % -------------------------------------------------------------
            % Batch
            % -------------------------------------------------------------
            batch = obj.BatchRepository.load( ...
                paths.experimentLocation(), ...
                experiments);
            messages(end + 1, 1) = "Batch object created successfully.";

            % -------------------------------------------------------------
            % Result
            % -------------------------------------------------------------
            result = obj.ResultRepository.open(paths.resultLocation());
            messages(end + 1, 1) = "Result object created successfully.";

            artifacts = ...
                openmebius.infrastructure.legacy.LegacyProjectArtifacts( ...
                Model = model, ...
                Experiments = experiments, ...
                Batch = batch, ...
                Result = result, ...
                Messages = messages);

        end

    end

end
