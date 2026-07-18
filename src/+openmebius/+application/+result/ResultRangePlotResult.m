classdef ResultRangePlotResult
    % RESULTRANGEPLOTRESULT Prepared bounds for a result range plot.

    properties (SetAccess = private)
        UpperBounds table
        LowerBounds table
        BestFits table
        ReactionNames (:, 1) string
        Messages (:, 1) string
    end

    methods

        function obj = ResultRangePlotResult(options)

            arguments
                options.UpperBounds table
                options.LowerBounds table
                options.BestFits table = table()
                options.ReactionNames (:, 1) string
                options.Messages (:, 1) string = strings(0, 1)
            end

            obj.UpperBounds = options.UpperBounds;
            obj.LowerBounds = options.LowerBounds;
            obj.BestFits = options.BestFits;
            obj.ReactionNames = options.ReactionNames;
            obj.Messages = options.Messages;

        end % constructor

    end % methods

end % classdef
