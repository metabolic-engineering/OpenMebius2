classdef ResultSuggestionService < handle
    % RESULTSUGGESTIONSERVICE Loads and prepares a next-label suggestion.

    methods

        function suggestionResult = load( ...
                ~, result, batchIDs, batchNames)

            arguments
                ~
                result
                batchIDs (:, 1) string
                batchNames (:, 1) string
            end

            openmebius.application.result.ResultSuggestionService ...
                .validateSelection(batchIDs, batchNames);
            openmebius.application.result.ResultSuggestionService ...
                .validateResult(result);

            batchID = batchIDs(1);
            batchName = batchNames(1);
            [isAvailable, suggestion] = ...
                result.getNextLabelSuggestion(batchID);

            if ~isAvailable
                error( ...
                    "OpenMebius2:ResultSuggestion:NotAvailable", ...
                    "No labeling suggestion is available for the " + ...
                    "selected result.");
            end

            if ~isstruct(suggestion) || ~isscalar(suggestion)
                error( ...
                    "OpenMebius2:ResultSuggestion:InvalidData", ...
                    "The labeling suggestion data is invalid.");
            end

            suggestion.sampleName = batchName;
            suggestion.batchID = batchID;

            suggestionResult = openmebius.application.result ...
                .ResultSuggestionResult( ...
                Suggestion = suggestion, ...
                BatchID = batchID, ...
                BatchName = batchName);

        end % load

    end % methods

    methods (Static, Access = private)

        function validateSelection(batchIDs, batchNames)

            if numel(batchIDs) ~= 1 || numel(batchNames) ~= 1
                error( ...
                    "OpenMebius2:ResultSuggestion:SelectionRequired", ...
                    "Please select one result to view suggestions.");
            end

        end % validateSelection

        function validateResult(result)

            if isempty(result)
                error( ...
                    "OpenMebius2:ResultSuggestion:ResultUnavailable", ...
                    "Result data is not available.");
            end

            if isa(result, "handle") && ~isvalid(result)
                error( ...
                    "OpenMebius2:ResultSuggestion:ResultUnavailable", ...
                    "Result data is not available.");
            end

        end % validateResult

    end % methods (Static, Access = private)

end % classdef
