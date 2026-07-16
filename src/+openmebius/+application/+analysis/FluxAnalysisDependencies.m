classdef FluxAnalysisDependencies
    % FLUXANALYSISDEPENDENCIES Aggregates resolved dependency groups.

    properties (SetAccess = private)
        Numerical
        Workflows
        Results
        Execution
    end

    properties (Dependent, SetAccess = private)
        FluxVariabilitySolver
        FluxVariabilityProblemFactory
        FluxVariabilityWorkflow
        InitialFluxWorkflow
        InitialFluxApplicationWorkflow
        MFAIterationApplicationWorkflow
        MFAIterationRunner
        MFAObjectiveFactory
        MFAIterationService
        MFAWorkflow
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
        MFAResultCoordinator
        AnalysisRunLifecycle
        RunContext
    end

    methods

        function obj = FluxAnalysisDependencies( ...
                configuration, hdf5FilePath, isExport, options)

            arguments
                configuration (1, 1) openmebius.application ...
                    .analysis.FluxAnalysisComposition
                hdf5FilePath (1, 1) string
                isExport (1, 1) logical
                options.ResultFactory = openmebius.application ...
                    .analysis.MFAResultDependenciesFactory()
                options.ExecutionFactory = openmebius.application ...
                    .analysis.MFAExecutionDependenciesFactory()
                options.NumericalFactory = openmebius.application ...
                    .analysis.MFANumericalDependenciesFactory()
                options.WorkflowFactory = openmebius.application ...
                    .analysis.MFAWorkflowDependenciesFactory()
            end

            obj.Results = options.ResultFactory.create( ...
                configuration.Results, hdf5FilePath, isExport);
            obj.Execution = options.ExecutionFactory.create( ...
                configuration.Execution, configuration.Results);
            obj.Numerical = options.NumericalFactory.create( ...
                configuration.Numerical);
            obj.Workflows = options.WorkflowFactory.create( ...
                configuration.Workflows, obj.Numerical);

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

        function value = get.InitialFluxWorkflow(obj)
            value = obj.Numerical.InitialFluxWorkflow;
        end

        function value = get.InitialFluxApplicationWorkflow(obj)
            value = obj.Workflows.InitialFluxApplicationWorkflow;
        end

        function value = get.MFAIterationApplicationWorkflow(obj)
            value = obj.Workflows.MFAIterationApplicationWorkflow;
        end

        function value = get.MFAIterationRunner(obj)
            value = obj.Numerical.MFAIterationRunner;
        end

        function value = get.MFAObjectiveFactory(obj)
            value = obj.Numerical.MFAObjectiveFactory;
        end

        function value = get.MFAIterationService(obj)
            value = obj.Numerical.MFAIterationService;
        end

        function value = get.MFAWorkflow(obj)
            value = obj.Numerical.MFAWorkflow;
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

        function value = get.MFAResultCoordinator(obj)
            value = obj.Results.MFAResultCoordinator;
        end

        function value = get.AnalysisRunLifecycle(obj)
            value = obj.Execution.AnalysisRunLifecycle;
        end

        function value = get.RunContext(obj)
            value = obj.Execution.RunContext;
        end

    end

end
