classdef MFAIterationApplicationResult
    % MFAITERATIONAPPLICATIONRESULT
    % Outcome of preparing and executing the MFA iterations.

    properties (SetAccess = private)
        WorkflowResult = []
        IsError (1, 1) logical = false
        IsCanceled (1, 1) logical = false
        FailureStage (1, 1) string = ""
        ErrorMessage (1, 1) string = ""
    end

    methods

        function obj = MFAIterationApplicationResult(options)

            arguments
                options.WorkflowResult = []
                options.IsError (1, 1) logical = false
                options.FailureStage (1, 1) string ...
                    {mustBeMember(options.FailureStage, ...
                    ["", "instationary", "optimization"])} = ""
                options.ErrorMessage (1, 1) string = ""
            end

            if options.IsError ~= (options.FailureStage ~= "")
                error( ...
                    "OpenMebius2:MFAIterationApplication:" + ...
                    "MissingFailureStage", ...
                    "Failed MFA iteration results must identify " + ...
                    "their failure stage.");
            end

            if options.IsError

                if ~isempty(options.WorkflowResult)
                    error( ...
                        "OpenMebius2:MFAIterationApplication:" + ...
                        "InconsistentResult", ...
                        "A failed MFA iteration result cannot " + ...
                        "contain a workflow result.");
                end

            elseif isempty(options.WorkflowResult)
                error( ...
                    "OpenMebius2:MFAIterationApplication:" + ...
                    "MissingWorkflowResult", ...
                    "A successful MFA iteration result must " + ...
                    "contain a workflow result.");
            end

            obj.WorkflowResult = options.WorkflowResult;
            obj.IsError = options.IsError;
            obj.FailureStage = options.FailureStage;
            obj.ErrorMessage = options.ErrorMessage;

            if ~isempty(options.WorkflowResult)
                obj.IsCanceled = options.WorkflowResult.IsCanceled;
            end

        end

    end

    methods (Static)

        function obj = failure(stage, message)

            obj = openmebius.application.analysis ...
                .MFAIterationApplicationResult( ...
                IsError = true, ...
                FailureStage = string(stage), ...
                ErrorMessage = string(message));

        end

    end

end
