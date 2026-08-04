classdef ResultSuggestionWorkspaceStub < handle

    properties
        IsAvailable (1, 1) logical = true
        Suggestion struct = struct("Value", 1)
        Called (1, 1) logical = false
        BatchID (1, 1) string = ""
        Exception = []
    end

    methods

        function [isAvailable, suggestion] = ...
                getNextLabelSuggestion(obj, batchID)

            obj.Called = true;
            obj.BatchID = batchID;

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

            isAvailable = obj.IsAvailable;
            suggestion = obj.Suggestion;

        end

    end

end
