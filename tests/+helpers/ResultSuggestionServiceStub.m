classdef ResultSuggestionServiceStub < handle

    properties
        Called (1, 1) logical = false
        ResultData = []
        BatchIDs (:, 1) string = strings(0, 1)
        BatchNames (:, 1) string = strings(0, 1)
        Result = []
        Exception = []
    end

    methods

        function result = load( ...
                obj, resultData, batchIDs, batchNames)

            obj.Called = true;
            obj.ResultData = resultData;
            obj.BatchIDs = batchIDs;
            obj.BatchNames = batchNames;

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

            result = obj.Result;

        end

    end

end
