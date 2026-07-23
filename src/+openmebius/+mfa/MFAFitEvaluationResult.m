classdef MFAFitEvaluationResult
    % MFAFITEVALUATIONRESULT
    % Immutable ordered objective values for candidate MFA fluxes.

    properties (SetAccess = private)
        ObjectiveValues (1, :) double
        Order (1, :) double
        ValidCount (1, 1) double
        IsCanceled (1, 1) logical
    end

    methods

        function obj = MFAFitEvaluationResult(options)

            arguments
                options.ObjectiveValues (1, :) double
                options.Order (1, :) double
                options.ValidCount (1, 1) double
                options.IsCanceled (1, 1) logical = false
            end

            candidateCount = numel(options.ObjectiveValues);

            if numel(options.Order) ~= candidateCount
                error( ...
                    "OpenMebius2:MFAFitStatistics:" + ...
                    "OrderSizeMismatch", ...
                    "Objective values and their order must have the " + ...
                "same length.");
            end

            if options.ValidCount < 0 || ...
                    options.ValidCount > candidateCount || ...
                    fix(options.ValidCount) ~= options.ValidCount
                error( ...
                    "OpenMebius2:MFAFitStatistics:" + ...
                    "InvalidValidCount", ...
                    "The valid candidate count is outside the result " + ...
                "range.");
            end

            obj.ObjectiveValues = options.ObjectiveValues;
            obj.Order = options.Order;
            obj.ValidCount = options.ValidCount;
            obj.IsCanceled = options.IsCanceled;

        end % constructor

    end % methods

end % classdef
