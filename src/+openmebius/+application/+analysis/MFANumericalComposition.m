classdef MFANumericalComposition
    % MFANUMERICALCOMPOSITION Configures numerical MFA services.

    properties (SetAccess = private)
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
        NextLabelExperimentWorkflow
        MFAInputValidator
        MFAFitStatistics
        MFAExperimentalDataBuilder
        MFAConstraintBuilder
        SubstrateEMUFactory
        SteadyStateMDVPredictor
        EffluxPenaltyFactory
        InstationaryInputFactory
    end

    methods

        function obj = MFANumericalComposition(options)

            arguments
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
                options.NextLabelExperimentWorkflow = []
                options.MFAInputValidator = ...
                    openmebius.mfa.MFAInputValidator()
                options.MFAFitStatistics = ...
                    openmebius.mfa.MFAFitStatistics()
                options.MFAExperimentalDataBuilder = ...
                    openmebius.mfa.MFAExperimentalDataBuilder()
                options.MFAConstraintBuilder = ...
                    openmebius.mfa.MFAConstraintBuilder()
                options.SubstrateEMUFactory = ...
                    openmebius.mfa.SubstrateEMUFactory()
                options.SteadyStateMDVPredictor = ...
                    openmebius.mfa.SteadyStateMDVPredictor()
                options.EffluxPenaltyFactory = ...
                    openmebius.mfa.EffluxPenaltyFactory()
                options.InstationaryInputFactory = ...
                    openmebius.mfa.InstationaryInputFactory()
            end

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
            obj.NextLabelExperimentWorkflow = ...
                options.NextLabelExperimentWorkflow;
            obj.MFAInputValidator = options.MFAInputValidator;
            obj.MFAFitStatistics = options.MFAFitStatistics;
            obj.MFAExperimentalDataBuilder = ...
                options.MFAExperimentalDataBuilder;
            obj.MFAConstraintBuilder = options.MFAConstraintBuilder;
            obj.SubstrateEMUFactory = options.SubstrateEMUFactory;
            obj.SteadyStateMDVPredictor = ...
                options.SteadyStateMDVPredictor;
            obj.EffluxPenaltyFactory = options.EffluxPenaltyFactory;
            obj.InstationaryInputFactory = ...
                options.InstationaryInputFactory;

        end

    end

end
