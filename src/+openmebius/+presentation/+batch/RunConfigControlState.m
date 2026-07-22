classdef RunConfigControlState
    % RUNCONFIGCONTROLSTATE Enable state for RunConfig control groups.

    properties (SetAccess = private)
        CIAlgorithmEnabled (1, 1) logical
        MonteCarloEnabled (1, 1) logical
        GridEnabled (1, 1) logical
        GridPointsEnabled (1, 1) logical
        GridDeltaEnabled (1, 1) logical
        GridReactionVisible (1, 1) logical
        EffluxEnabled (1, 1) logical
        SuggestionEnabled (1, 1) logical
        INSTMFATablesEnabled (1, 1) logical
    end

    methods

        function obj = RunConfigControlState(options)

            arguments
                options.CIAlgorithmEnabled (1, 1) logical = false
                options.MonteCarloEnabled (1, 1) logical = false
                options.GridEnabled (1, 1) logical = false
                options.GridPointsEnabled (1, 1) logical = false
                options.GridDeltaEnabled (1, 1) logical = false
                options.GridReactionVisible (1, 1) logical = false
                options.EffluxEnabled (1, 1) logical = false
                options.SuggestionEnabled (1, 1) logical = false
                options.INSTMFATablesEnabled (1, 1) logical = false
            end

            obj.CIAlgorithmEnabled = options.CIAlgorithmEnabled;
            obj.MonteCarloEnabled = options.MonteCarloEnabled;
            obj.GridEnabled = options.GridEnabled;
            obj.GridPointsEnabled = options.GridPointsEnabled;
            obj.GridDeltaEnabled = options.GridDeltaEnabled;
            obj.GridReactionVisible = options.GridReactionVisible;
            obj.EffluxEnabled = options.EffluxEnabled;
            obj.SuggestionEnabled = options.SuggestionEnabled;
            obj.INSTMFATablesEnabled = ...
                options.INSTMFATablesEnabled;

        end % constructor

    end % methods

end % classdef
