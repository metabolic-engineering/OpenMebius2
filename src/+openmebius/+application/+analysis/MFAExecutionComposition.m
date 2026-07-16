classdef MFAExecutionComposition
    % MFAEXECUTIONCOMPOSITION Configures analysis runtime services.

    properties (SetAccess = private)
        RuntimeFactory
        AnalysisControllerFactory
        MFAExperimentListNormalizer
        AnalysisRunLifecycle
        RunContext
    end

    methods

        function obj = MFAExecutionComposition(options)

            arguments
                options.RuntimeFactory = []
                options.AnalysisControllerFactory = ...
                    openmebius.application.analysis ...
                    .MFAAnalysisControllerFactory()
                options.MFAExperimentListNormalizer = ...
                    openmebius.mfa.MFAExperimentListNormalizer()
                options.AnalysisRunLifecycle = []
                options.RunContext = []
            end

            obj.RuntimeFactory = options.RuntimeFactory;
            obj.AnalysisControllerFactory = ...
                options.AnalysisControllerFactory;
            obj.MFAExperimentListNormalizer = ...
                options.MFAExperimentListNormalizer;
            obj.AnalysisRunLifecycle = options.AnalysisRunLifecycle;
            obj.RunContext = options.RunContext;

        end

    end

end
