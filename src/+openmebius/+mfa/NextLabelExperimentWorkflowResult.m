classdef NextLabelExperimentWorkflowResult
    % NEXTLABELEXPERIMENTWORKFLOWRESULT
    % Immutable collection of evaluated next-label patterns.

    properties (SetAccess = private)
        Patterns cell = {}
        LowerBounds cell = {}
        UpperBounds cell = {}
        Outputs cell = {}
        IsCanceled (1, 1) logical = false
    end

    methods

        function obj = NextLabelExperimentWorkflowResult(options)

            arguments
                options.Patterns cell = {}
                options.LowerBounds cell = {}
                options.UpperBounds cell = {}
                options.Outputs cell = {}
                options.IsCanceled (1, 1) logical = false
            end

            count = numel(options.Patterns);

            if numel(options.LowerBounds) ~= count || ...
                    numel(options.UpperBounds) ~= count || ...
                    numel(options.Outputs) ~= count
                error( ...
                    "OpenMebius2:NextLabelExperimentWorkflow:" + ...
                    "ResultSizeMismatch", ...
                    "Each evaluated pattern must have one result.");
            end

            obj.Patterns = options.Patterns;
            obj.LowerBounds = options.LowerBounds;
            obj.UpperBounds = options.UpperBounds;
            obj.Outputs = options.Outputs;
            obj.IsCanceled = options.IsCanceled;

        end

    end

end
