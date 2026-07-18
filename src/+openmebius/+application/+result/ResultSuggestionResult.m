classdef ResultSuggestionResult
    % RESULTSUGGESTIONRESULT Prepared next-label suggestion data.

    properties (SetAccess = private)
        Suggestion struct
        BatchID (1, 1) string
        BatchName (1, 1) string
    end

    methods

        function obj = ResultSuggestionResult(options)

            arguments
                options.Suggestion struct
                options.BatchID (1, 1) string
                options.BatchName (1, 1) string
            end

            obj.Suggestion = options.Suggestion;
            obj.BatchID = options.BatchID;
            obj.BatchName = options.BatchName;

        end % constructor

    end % methods

end % classdef
