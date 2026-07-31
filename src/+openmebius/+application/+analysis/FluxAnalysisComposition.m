classdef FluxAnalysisComposition
    % FLUXANALYSISCOMPOSITION Grouped configuration for MFA analysis.

    properties (SetAccess = private)
        Numerical
        Workflows
        Results
        Execution
    end

    properties (Dependent, SetAccess = private)
        RuntimeFactory
        AnalysisControllerFactory
        Hdf5ResultRepository
        MFAInputSnapshotWriter
        MFAResultCheckpointWriter
        NextLabelResultCheckpointWriter
        MFAResultCoordinator
        ResultManifestRepository
        FluxVariabilitySolver
        FluxVariabilityProblemFactory
        FluxVariabilityWorkflow
        InitialPointGenerator
        InitialFluxWorkflow
        InitialFluxApplicationWorkflow
        MFAIterationApplicationWorkflow
        MFAProblemFactory
        SteadyStateSolver
        MFAIterationRunner
        MFAWorkflow
        MonteCarloConfidenceIntervalSolver
        ConfidenceIntervalWorkflow
        ConfidenceIntervalApplicationWorkflow
        NextLabelExperimentWorkflow
        NextFluxExperimentWorkflow
        MFAInputValidator
        MFAInputPreparationWorkflow
        FluxDistributionWorkflow
        MFAFitStatistics
        MFAExperimentalDataBuilder
        MFAConstraintBuilder
        MFAExperimentListNormalizer
        SubstrateEMUFactory
        SteadyStateMDVPredictor
        EffluxPenaltyFactory
        InstationaryInputFactory
        AnalysisRunLifecycle
        RunContext
    end

    methods

        function obj = FluxAnalysisComposition(options)

            arguments
                options.Numerical = []
                options.Workflows = []
                options.Results = []
                options.Execution = []
                options.RuntimeFactory = []
                options.AnalysisControllerFactory = ...
                    openmebius.application.analysis ...
                    .MFAAnalysisControllerFactory()
                options.Hdf5ResultRepository = ...
                    openmebius.infrastructure.result ...
                    .Hdf5ResultRepository()
                options.MFAInputSnapshotWriter = []
                options.MFAResultCheckpointWriter = []
                options.NextLabelResultCheckpointWriter = []
                options.MFAResultCoordinator = []
                options.ResultManifestRepository = ...
                    openmebius.infrastructure.result ...
                    .ResultManifestRepository()
                options.FluxVariabilitySolver = ...
                    openmebius.mfa.FluxVariabilitySolver()
                options.FluxVariabilityProblemFactory = []
                options.FluxVariabilityWorkflow = []
                options.InitialPointGenerator = ...
                    openmebius.mfa.InitialPointGenerator()
                options.InitialFluxWorkflow = []
                options.InitialFluxApplicationWorkflow = []
                options.MFAIterationApplicationWorkflow = []
                options.MFAProblemFactory = ...
                    openmebius.mfa.MFAProblemFactory()
                options.SteadyStateSolver = ...
                    openmebius.mfa.SteadyStateSolver()
                options.MFAIterationRunner = []
                options.MFAWorkflow = openmebius.mfa.MFAWorkflow()
                options.MonteCarloConfidenceIntervalSolver = ...
                    openmebius.mfa ...
                    .MonteCarloConfidenceIntervalSolver()
                options.ConfidenceIntervalWorkflow = []
                options.ConfidenceIntervalApplicationWorkflow = []
                options.NextLabelExperimentWorkflow = []
                options.NextFluxExperimentWorkflow = []
                options.MFAInputValidator = ...
                    openmebius.mfa.MFAInputValidator()
                options.MFAInputPreparationWorkflow = []
                options.FluxDistributionWorkflow = []
                options.MFAFitStatistics = ...
                    openmebius.mfa.MFAFitStatistics()
                options.MFAExperimentalDataBuilder = ...
                    openmebius.mfa.MFAExperimentalDataBuilder()
                options.MFAConstraintBuilder = ...
                    openmebius.mfa.MFAConstraintBuilder()
                options.MFAExperimentListNormalizer = ...
                    openmebius.mfa.MFAExperimentListNormalizer()
                options.SubstrateEMUFactory = ...
                    openmebius.mfa.SubstrateEMUFactory()
                options.SteadyStateMDVPredictor = ...
                    openmebius.mfa.SteadyStateMDVPredictor()
                options.EffluxPenaltyFactory = ...
                    openmebius.mfa.EffluxPenaltyFactory()
                options.InstationaryInputFactory = ...
                    openmebius.mfa.InstationaryInputFactory()
                options.AnalysisRunLifecycle = []
                options.RunContext = []
            end

            obj.Numerical = options.Numerical;

            if isempty(obj.Numerical)
                obj.Numerical = openmebius.application.analysis ...
                    .MFANumericalComposition( ...
                    FluxVariabilitySolver = ...
                    options.FluxVariabilitySolver, ...
                    FluxVariabilityProblemFactory = ...
                    options.FluxVariabilityProblemFactory, ...
                    FluxVariabilityWorkflow = ...
                    options.FluxVariabilityWorkflow, ...
                    InitialPointGenerator = ...
                    options.InitialPointGenerator, ...
                    InitialFluxWorkflow = options.InitialFluxWorkflow, ...
                    MFAProblemFactory = options.MFAProblemFactory, ...
                    SteadyStateSolver = options.SteadyStateSolver, ...
                    MFAIterationRunner = options.MFAIterationRunner, ...
                    MFAWorkflow = options.MFAWorkflow, ...
                    MonteCarloConfidenceIntervalSolver = ...
                    options.MonteCarloConfidenceIntervalSolver, ...
                    ConfidenceIntervalWorkflow = ...
                    options.ConfidenceIntervalWorkflow, ...
                    NextLabelExperimentWorkflow = ...
                    options.NextLabelExperimentWorkflow, ...
                    MFAInputValidator = options.MFAInputValidator, ...
                    MFAFitStatistics = options.MFAFitStatistics, ...
                    MFAExperimentalDataBuilder = ...
                    options.MFAExperimentalDataBuilder, ...
                    MFAConstraintBuilder = ...
                    options.MFAConstraintBuilder, ...
                    SubstrateEMUFactory = options.SubstrateEMUFactory, ...
                    SteadyStateMDVPredictor = ...
                    options.SteadyStateMDVPredictor, ...
                    EffluxPenaltyFactory = ...
                    options.EffluxPenaltyFactory, ...
                    InstationaryInputFactory = ...
                    options.InstationaryInputFactory);
            end

            obj.Workflows = options.Workflows;

            if isempty(obj.Workflows)
                obj.Workflows = openmebius.application.analysis ...
                    .MFAWorkflowComposition( ...
                    MFAInputPreparationWorkflow = ...
                    options.MFAInputPreparationWorkflow, ...
                    InitialFluxApplicationWorkflow = ...
                    options.InitialFluxApplicationWorkflow, ...
                    MFAIterationApplicationWorkflow = ...
                    options.MFAIterationApplicationWorkflow, ...
                    ConfidenceIntervalApplicationWorkflow = ...
                    options.ConfidenceIntervalApplicationWorkflow, ...
                    NextFluxExperimentWorkflow = ...
                    options.NextFluxExperimentWorkflow, ...
                    FluxDistributionWorkflow = ...
                    options.FluxDistributionWorkflow);
            end

            obj.Results = options.Results;

            if isempty(obj.Results)
                obj.Results = openmebius.application.analysis ...
                    .MFAResultComposition( ...
                    Hdf5ResultRepository = ...
                    options.Hdf5ResultRepository, ...
                    MFAInputSnapshotWriter = ...
                    options.MFAInputSnapshotWriter, ...
                    MFAResultCheckpointWriter = ...
                    options.MFAResultCheckpointWriter, ...
                    NextLabelResultCheckpointWriter = ...
                    options.NextLabelResultCheckpointWriter, ...
                    MFAResultCoordinator = ...
                    options.MFAResultCoordinator, ...
                    ResultManifestRepository = ...
                    options.ResultManifestRepository);
            end

            obj.Execution = options.Execution;

            if isempty(obj.Execution)
                obj.Execution = openmebius.application.analysis ...
                    .MFAExecutionComposition( ...
                    RuntimeFactory = options.RuntimeFactory, ...
                    AnalysisControllerFactory = ...
                    options.AnalysisControllerFactory, ...
                    MFAExperimentListNormalizer = ...
                    options.MFAExperimentListNormalizer, ...
                    AnalysisRunLifecycle = ...
                    options.AnalysisRunLifecycle, ...
                    RunContext = options.RunContext);
            end

        end

        function value = get.RuntimeFactory(obj)
            value = obj.Execution.RuntimeFactory;
        end

        function value = get.AnalysisControllerFactory(obj)
            value = obj.Execution.AnalysisControllerFactory;
        end

        function value = get.Hdf5ResultRepository(obj)
            value = obj.Results.Hdf5ResultRepository;
        end

        function value = get.MFAInputSnapshotWriter(obj)
            value = obj.Results.MFAInputSnapshotWriter;
        end

        function value = get.MFAResultCheckpointWriter(obj)
            value = obj.Results.MFAResultCheckpointWriter;
        end

        function value = get.NextLabelResultCheckpointWriter(obj)
            value = obj.Results.NextLabelResultCheckpointWriter;
        end

        function value = get.MFAResultCoordinator(obj)
            value = obj.Results.MFAResultCoordinator;
        end

        function value = get.ResultManifestRepository(obj)
            value = obj.Results.ResultManifestRepository;
        end

        function value = get.FluxVariabilitySolver(obj)
            value = obj.Numerical.FluxVariabilitySolver;
        end

        function value = get.FluxVariabilityProblemFactory(obj)
            value = obj.Numerical.FluxVariabilityProblemFactory;
        end

        function value = get.FluxVariabilityWorkflow(obj)
            value = obj.Numerical.FluxVariabilityWorkflow;
        end

        function value = get.InitialPointGenerator(obj)
            value = obj.Numerical.InitialPointGenerator;
        end

        function value = get.InitialFluxWorkflow(obj)
            value = obj.Numerical.InitialFluxWorkflow;
        end

        function value = get.InitialFluxApplicationWorkflow(obj)
            value = obj.Workflows.InitialFluxApplicationWorkflow;
        end

        function value = get.MFAIterationApplicationWorkflow(obj)
            value = obj.Workflows.MFAIterationApplicationWorkflow;
        end

        function value = get.MFAProblemFactory(obj)
            value = obj.Numerical.MFAProblemFactory;
        end

        function value = get.SteadyStateSolver(obj)
            value = obj.Numerical.SteadyStateSolver;
        end

        function value = get.MFAIterationRunner(obj)
            value = obj.Numerical.MFAIterationRunner;
        end

        function value = get.MFAWorkflow(obj)
            value = obj.Numerical.MFAWorkflow;
        end

        function value = get.MonteCarloConfidenceIntervalSolver(obj)
            value = obj.Numerical.MonteCarloConfidenceIntervalSolver;
        end

        function value = get.ConfidenceIntervalWorkflow(obj)
            value = obj.Numerical.ConfidenceIntervalWorkflow;
        end

        function value = get.ConfidenceIntervalApplicationWorkflow(obj)
            value = obj.Workflows.ConfidenceIntervalApplicationWorkflow;
        end

        function value = get.NextLabelExperimentWorkflow(obj)
            value = obj.Numerical.NextLabelExperimentWorkflow;
        end

        function value = get.NextFluxExperimentWorkflow(obj)
            value = obj.Workflows.NextFluxExperimentWorkflow;
        end

        function value = get.MFAInputValidator(obj)
            value = obj.Numerical.MFAInputValidator;
        end

        function value = get.MFAInputPreparationWorkflow(obj)
            value = obj.Workflows.MFAInputPreparationWorkflow;
        end

        function value = get.FluxDistributionWorkflow(obj)
            value = obj.Workflows.FluxDistributionWorkflow;
        end

        function value = get.MFAFitStatistics(obj)
            value = obj.Numerical.MFAFitStatistics;
        end

        function value = get.MFAExperimentalDataBuilder(obj)
            value = obj.Numerical.MFAExperimentalDataBuilder;
        end

        function value = get.MFAConstraintBuilder(obj)
            value = obj.Numerical.MFAConstraintBuilder;
        end

        function value = get.MFAExperimentListNormalizer(obj)
            value = obj.Execution.MFAExperimentListNormalizer;
        end

        function value = get.SubstrateEMUFactory(obj)
            value = obj.Numerical.SubstrateEMUFactory;
        end

        function value = get.SteadyStateMDVPredictor(obj)
            value = obj.Numerical.SteadyStateMDVPredictor;
        end

        function value = get.EffluxPenaltyFactory(obj)
            value = obj.Numerical.EffluxPenaltyFactory;
        end

        function value = get.InstationaryInputFactory(obj)
            value = obj.Numerical.InstationaryInputFactory;
        end

        function value = get.AnalysisRunLifecycle(obj)
            value = obj.Execution.AnalysisRunLifecycle;
        end

        function value = get.RunContext(obj)
            value = obj.Execution.RunContext;
        end

    end

end
