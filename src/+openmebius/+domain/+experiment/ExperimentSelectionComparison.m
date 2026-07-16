classdef ExperimentSelectionComparison
    % EXPERIMENTSELECTIONCOMPARISON Typed fragment-selection comparison.

    properties (SetAccess = private)
        Selected table
        Available table
        IsAvailable (1, 1) logical
        Message (1, 1) string
    end

    methods

        function obj = ExperimentSelectionComparison(options)

            arguments
                options.Selected table = table()
                options.Available table = table()
                options.IsAvailable (1, 1) logical = true
                options.Message (1, 1) string = ""
            end

            obj.Selected = options.Selected;
            obj.Available = options.Available;
            obj.IsAvailable = options.IsAvailable;
            obj.Message = options.Message;

        end % constructor

    end % methods

end % classdef
