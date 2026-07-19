classdef MFAExecutionDependencies
    % MFAEXECUTIONDEPENDENCIES Resolved runtime dependencies.

    properties (SetAccess = private)
        MFAExperimentListNormalizer
        AnalysisRunLifecycle
        RunContext (1, 1) openmebius.application.analysis ...
            .MFAAnalysisRunContext
    end

    methods

        function obj = MFAExecutionDependencies(options)

            arguments
                options.MFAExperimentListNormalizer
                options.AnalysisRunLifecycle
                options.RunContext (1, 1) openmebius.application ...
                    .analysis.MFAAnalysisRunContext
            end

            obj.MFAExperimentListNormalizer = ...
                options.MFAExperimentListNormalizer;
            obj.AnalysisRunLifecycle = options.AnalysisRunLifecycle;
            obj.RunContext = options.RunContext;

        end

    end

end
