classdef ExperimentComparisonResult
    % EXPERIMENTCOMPARISONRESULT Typed result for one comparison table.

    properties (SetAccess = private)
        Data table
        ErrorMask logical
        IsAvailable (1, 1) logical
        Message (1, 1) string
    end

    methods

        function obj = ExperimentComparisonResult(options)

            arguments
                options.Data table = table()
                options.ErrorMask logical = false(0, 0)
                options.IsAvailable (1, 1) logical = true
                options.Message (1, 1) string = ""
            end

            obj.Data = options.Data;
            obj.ErrorMask = options.ErrorMask;
            obj.IsAvailable = options.IsAvailable;
            obj.Message = options.Message;

        end % constructor

    end % methods

end % classdef
