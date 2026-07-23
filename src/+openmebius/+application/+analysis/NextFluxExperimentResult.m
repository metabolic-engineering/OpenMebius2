classdef NextFluxExperimentResult
    % NEXTFLUXEXPERIMENTRESULT
    % Outcome of confidence-interval based experiment suggestion.

    properties (SetAccess = private)
        ConfidenceIntervalResult = []
        SuggestionResult = []
        LowerBounds double = []
        UpperBounds double = []
        Output (1, 1) struct = struct
        IsCanceled (1, 1) logical = false
        IsError (1, 1) logical = false
        ErrorMessage (1, 1) string = ""
    end

    methods

        function obj = NextFluxExperimentResult(options)

            arguments
                options.ConfidenceIntervalResult = []
                options.SuggestionResult = []
                options.LowerBounds double = []
                options.UpperBounds double = []
                options.Output (1, 1) struct = struct
                options.IsCanceled (1, 1) logical = false
                options.IsError (1, 1) logical = false
                options.ErrorMessage (1, 1) string = ""
            end

            if ~isequal( ...
                    size(options.LowerBounds), ...
                    size(options.UpperBounds))
                error( ...
                    "OpenMebius2:NextFluxExperiment:" + ...
                    "BoundSizeMismatch", ...
                    "Next-experiment confidence bounds must have " + ...
                "the same size.");
            end

            if options.IsCanceled && options.IsError
                error( ...
                    "OpenMebius2:NextFluxExperiment:" + ...
                    "InconsistentResult", ...
                    "A next-experiment run cannot be both failed " + ...
                "and canceled.");
            end

            if options.IsError && strlength(options.ErrorMessage) == 0
                error( ...
                    "OpenMebius2:NextFluxExperiment:" + ...
                    "MissingErrorMessage", ...
                    "Failed next-experiment results must include an " + ...
                "error message.");
            end

            obj.ConfidenceIntervalResult = ...
                options.ConfidenceIntervalResult;
            obj.SuggestionResult = options.SuggestionResult;
            obj.LowerBounds = options.LowerBounds;
            obj.UpperBounds = options.UpperBounds;
            obj.Output = options.Output;
            obj.IsCanceled = options.IsCanceled;
            obj.IsError = options.IsError;
            obj.ErrorMessage = options.ErrorMessage;

        end

    end

end
