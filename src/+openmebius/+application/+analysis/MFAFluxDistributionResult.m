classdef MFAFluxDistributionResult
    % MFAFLUXDISTRIBUTIONRESULT
    % Outcome of the application-level flux-distribution workflow.

    properties (SetAccess = private)
        InputPreparation = []
        WorkflowResult = []
        MinimumObjective (1, 1) double = NaN
        IsError (1, 1) logical = false
        IsCanceled (1, 1) logical = false
        FailureStage (1, 1) string = ""
        ErrorMessage (1, 1) string = ""
    end

    methods

        function obj = MFAFluxDistributionResult(options)

            arguments
                options.InputPreparation = []
                options.WorkflowResult = []
                options.MinimumObjective (1, 1) double = NaN
                options.IsError (1, 1) logical = false
                options.IsCanceled (1, 1) logical = false
                options.FailureStage (1, 1) string ...
                    {mustBeMember(options.FailureStage, ...
                    ["", "input", "fva", "initial", ...
                    "instationary", "optimization"])} = ""
                options.ErrorMessage (1, 1) string = ""
            end

            if options.IsError && options.IsCanceled
                error( ...
                    "OpenMebius2:MFAFluxDistribution:" + ...
                    "InconsistentResult", ...
                    "A flux-distribution run cannot be both failed " + ...
                    "and canceled.");
            end

            if options.IsError ~= (options.FailureStage ~= "")
                error( ...
                    "OpenMebius2:MFAFluxDistribution:" + ...
                    "MissingFailureStage", ...
                    "Failed flux-distribution results must identify " + ...
                    "their failure stage.");
            end

            obj.InputPreparation = options.InputPreparation;
            obj.WorkflowResult = options.WorkflowResult;
            obj.MinimumObjective = options.MinimumObjective;
            obj.IsError = options.IsError;
            obj.IsCanceled = options.IsCanceled;
            obj.FailureStage = options.FailureStage;
            obj.ErrorMessage = options.ErrorMessage;

        end

    end

end
