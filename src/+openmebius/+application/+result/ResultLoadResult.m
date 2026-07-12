classdef ResultLoadResult

    properties (SetAccess = private)
        Result
        ResultLocation openmebius.domain.result.ResultLocation
        Messages (:, 1) string
    end

    methods

        function obj = ResultLoadResult(options)

            arguments
                options.Result
                options.ResultLocation openmebius.domain.result.ResultLocation
                options.Messages (:, 1) string = strings(0, 1)
            end

            obj.Result = options.Result;
            obj.ResultLocation = options.ResultLocation;
            obj.Messages = options.Messages;

        end

    end

end
