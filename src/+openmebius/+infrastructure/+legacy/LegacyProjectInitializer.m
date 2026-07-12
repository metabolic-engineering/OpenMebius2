classdef LegacyProjectInitializer < handle
    % LEGACYPROJECTINITIALIZER
    % Creates legacy runtime objects for a newly created project.
    %
    % New projects may not contain experiment workbooks yet. Unlike
    % LegacyProjectLoader, this initializer only requires the model and
    % result locations to be usable.

    properties (Access = private)
        ModelRepository
        ExperimentRepository
        BatchRepository
        ResultRepository
    end

    methods

        function obj = LegacyProjectInitializer(options)

            arguments
                options.ModelRepository = ...
                    openmebius.infrastructure.model.ModelRepository()
                options.ExperimentRepository = ...
                    openmebius.infrastructure.experiment.ExperimentRepository()
                options.BatchRepository = ...
                    openmebius.infrastructure.legacy.LegacyBatchRepository()
                options.ResultRepository = ...
                    openmebius.infrastructure.legacy.LegacyResultRepository()
            end

            obj.ModelRepository = options.ModelRepository;
            obj.ExperimentRepository = options.ExperimentRepository;
            obj.BatchRepository = options.BatchRepository;
            obj.ResultRepository = options.ResultRepository;

        end

        function artifacts = initialize(obj, session)

            arguments
                obj
                session openmebius.domain.project.ProjectSession
            end

            paths = session.Paths;
            messages = strings(0, 1);

            model = obj.ModelRepository.load(paths.modelLocation());
            messages(end + 1, 1) = "Model loaded successfully.";

            experiments = obj.ExperimentRepository.load( ...
                paths.experimentLocation(), ...
                model);
            messages(end + 1, 1) = "Experiment object created successfully.";

            batch = obj.BatchRepository.load( ...
                paths.experimentLocation(), ...
                experiments);
            messages(end + 1, 1) = "Batch object created successfully.";

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
