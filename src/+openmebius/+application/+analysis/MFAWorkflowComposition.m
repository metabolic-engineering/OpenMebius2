classdef MFAWorkflowComposition
    % MFAWORKFLOWCOMPOSITION Configures application-level workflows.

    properties (SetAccess = private)
        MFAInputPreparationWorkflow
        InitialFluxApplicationWorkflow
        MFAIterationApplicationWorkflow
        ConfidenceIntervalApplicationWorkflow
        NextFluxExperimentWorkflow
        FluxDistributionWorkflow
    end

    methods

        function obj = MFAWorkflowComposition(options)

            arguments
                options.MFAInputPreparationWorkflow = []
                options.InitialFluxApplicationWorkflow = []
                options.MFAIterationApplicationWorkflow = []
                options.ConfidenceIntervalApplicationWorkflow = []
                options.NextFluxExperimentWorkflow = []
                options.FluxDistributionWorkflow = []
            end

            obj.MFAInputPreparationWorkflow = ...
                options.MFAInputPreparationWorkflow;
            obj.InitialFluxApplicationWorkflow = ...
                options.InitialFluxApplicationWorkflow;
            obj.MFAIterationApplicationWorkflow = ...
                options.MFAIterationApplicationWorkflow;
            obj.ConfidenceIntervalApplicationWorkflow = ...
                options.ConfidenceIntervalApplicationWorkflow;
            obj.NextFluxExperimentWorkflow = ...
                options.NextFluxExperimentWorkflow;
            obj.FluxDistributionWorkflow = ...
                options.FluxDistributionWorkflow;

        end

    end

end
