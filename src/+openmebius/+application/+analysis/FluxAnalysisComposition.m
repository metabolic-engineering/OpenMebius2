classdef FluxAnalysisComposition
    % FLUXANALYSISCOMPOSITION
    % Immutable service configuration for one FluxAnalysis facade.

    properties (SetAccess = private)
        RuntimeFactory
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
                options.RuntimeFactory = []
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

            obj.RuntimeFactory = options.RuntimeFactory;
            obj.Hdf5ResultRepository = ...
                options.Hdf5ResultRepository;
            obj.MFAInputSnapshotWriter = ...
                options.MFAInputSnapshotWriter;
            obj.MFAResultCheckpointWriter = ...
                options.MFAResultCheckpointWriter;
            obj.NextLabelResultCheckpointWriter = ...
                options.NextLabelResultCheckpointWriter;
            obj.MFAResultCoordinator = options.MFAResultCoordinator;
            obj.ResultManifestRepository = ...
                options.ResultManifestRepository;
            obj.FluxVariabilitySolver = ...
                options.FluxVariabilitySolver;
            obj.FluxVariabilityProblemFactory = ...
                options.FluxVariabilityProblemFactory;
            obj.FluxVariabilityWorkflow = ...
                options.FluxVariabilityWorkflow;
            obj.InitialPointGenerator = options.InitialPointGenerator;
            obj.InitialFluxWorkflow = options.InitialFluxWorkflow;
            obj.MFAProblemFactory = options.MFAProblemFactory;
            obj.SteadyStateSolver = options.SteadyStateSolver;
            obj.MFAIterationRunner = options.MFAIterationRunner;
            obj.MFAWorkflow = options.MFAWorkflow;
            obj.MonteCarloConfidenceIntervalSolver = ...
                options.MonteCarloConfidenceIntervalSolver;
            obj.ConfidenceIntervalWorkflow = ...
                options.ConfidenceIntervalWorkflow;
            obj.ConfidenceIntervalApplicationWorkflow = ...
                options.ConfidenceIntervalApplicationWorkflow;
            obj.NextLabelExperimentWorkflow = ...
                options.NextLabelExperimentWorkflow;
            obj.NextFluxExperimentWorkflow = ...
                options.NextFluxExperimentWorkflow;
            obj.MFAInputValidator = options.MFAInputValidator;
            obj.MFAInputPreparationWorkflow = ...
                options.MFAInputPreparationWorkflow;
            obj.FluxDistributionWorkflow = ...
                options.FluxDistributionWorkflow;
            obj.MFAFitStatistics = options.MFAFitStatistics;
            obj.MFAExperimentalDataBuilder = ...
                options.MFAExperimentalDataBuilder;
            obj.MFAConstraintBuilder = options.MFAConstraintBuilder;
            obj.MFAExperimentListNormalizer = ...
                options.MFAExperimentListNormalizer;
            obj.SubstrateEMUFactory = options.SubstrateEMUFactory;
            obj.SteadyStateMDVPredictor = ...
                options.SteadyStateMDVPredictor;
            obj.EffluxPenaltyFactory = options.EffluxPenaltyFactory;
            obj.InstationaryInputFactory = ...
                options.InstationaryInputFactory;
            obj.AnalysisRunLifecycle = options.AnalysisRunLifecycle;
            obj.RunContext = options.RunContext;

        end

    end

end
