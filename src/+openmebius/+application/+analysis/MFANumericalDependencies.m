classdef MFANumericalDependencies
    % MFANUMERICALDEPENDENCIES Resolved numerical MFA services.

    properties (SetAccess = private)
        FluxVariabilitySolver
        FluxVariabilityProblemFactory
        FluxVariabilityWorkflow
        InitialFluxWorkflow
        MFAIterationRunner
        MFAObjectiveFactory
        MFAIterationService
        MFAWorkflow
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

        function obj = MFANumericalDependencies(options)

            arguments
                options.FluxVariabilitySolver
                options.FluxVariabilityProblemFactory
                options.FluxVariabilityWorkflow
                options.InitialFluxWorkflow
                options.MFAIterationRunner
                options.MFAObjectiveFactory
                options.MFAIterationService
                options.MFAWorkflow
                options.ConfidenceIntervalWorkflow
                options.NextLabelExperimentWorkflow
                options.MFAInputValidator
                options.MFAFitStatistics
                options.MFAExperimentalDataBuilder
                options.MFAConstraintBuilder
                options.SubstrateEMUFactory
                options.SteadyStateMDVPredictor
                options.EffluxPenaltyFactory
                options.InstationaryInputFactory
            end

            obj.FluxVariabilitySolver = ...
                options.FluxVariabilitySolver;
            obj.FluxVariabilityProblemFactory = ...
                options.FluxVariabilityProblemFactory;
            obj.FluxVariabilityWorkflow = ...
                options.FluxVariabilityWorkflow;
            obj.InitialFluxWorkflow = options.InitialFluxWorkflow;
            obj.MFAIterationRunner = options.MFAIterationRunner;
            obj.MFAObjectiveFactory = options.MFAObjectiveFactory;
            obj.MFAIterationService = options.MFAIterationService;
            obj.MFAWorkflow = options.MFAWorkflow;
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
