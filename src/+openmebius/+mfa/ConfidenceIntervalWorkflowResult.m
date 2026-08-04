classdef ConfidenceIntervalWorkflowResult
    % CONFIDENCEINTERVALWORKFLOWRESULT
    % Immutable output and state of a confidence-interval workflow.

    properties (SetAccess = private)
        LowerBounds double = []
        UpperBounds double = []
        Output (1, 1) struct = struct
        Method (1, 1) string = ""
        IsCalculated (1, 1) logical = false
        IsCanceled (1, 1) logical = false
        IsError (1, 1) logical = false
        ErrorMessage (1, 1) string = ""
    end

    methods

        function obj = ConfidenceIntervalWorkflowResult(options)

            arguments
                options.LowerBounds double = []
                options.UpperBounds double = []
                options.Output (1, 1) struct = struct
                options.Method (1, 1) string = ""
                options.IsCalculated (1, 1) logical = false
                options.IsCanceled (1, 1) logical = false
                options.IsError (1, 1) logical = false
                options.ErrorMessage (1, 1) string = ""
            end

            if ~isequal( ...
                    size(options.LowerBounds), ...
                    size(options.UpperBounds))
                error( ...
                    "OpenMebius2:ConfidenceIntervalWorkflow:" + ...
                    "BoundSizeMismatch", ...
                    "Confidence-interval bounds must have the same size.");
            end

            obj.LowerBounds = options.LowerBounds;
            obj.UpperBounds = options.UpperBounds;
            obj.Output = options.Output;
            obj.Method = options.Method;
            obj.IsCalculated = options.IsCalculated;
            obj.IsCanceled = options.IsCanceled;
            obj.IsError = options.IsError;
            obj.ErrorMessage = options.ErrorMessage;

        end

    end

end
