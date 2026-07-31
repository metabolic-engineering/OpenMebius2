classdef ResultRangePlotService < handle
    % RESULTRANGEPLOTSERVICE Prepares aligned bounds for result comparison.

    methods

        function plotResult = prepare(~, result, batchIDs, batchNames)

            arguments
                ~
                result
                batchIDs (:, 1) string
                batchNames (:, 1) string
            end

            openmebius.application.result.ResultRangePlotService ...
                .validateSelection(batchIDs, batchNames);
            openmebius.application.result.ResultRangePlotService ...
                .validateResult(result);

            numberOfBatches = numel(batchIDs);
            overviews = cell(numberOfBatches, 1);

            for batchIndex = 1:numberOfBatches
                overview = result.getFluxOverView(batchIDs(batchIndex));
                openmebius.application.result.ResultRangePlotService ...
                    .validateOverview(overview, batchIDs(batchIndex));
                overviews{batchIndex} = overview;
            end

            reactionIDs = string(overviews{1}.Properties.RowNames);
            reactionIDs = reactionIDs(:);
            numberOfReactions = numel(reactionIDs);
            lowerBounds = nan(numberOfReactions, numberOfBatches);
            upperBounds = nan(numberOfReactions, numberOfBatches);
            bestFits = nan(numberOfReactions, numberOfBatches);
            usedFvaBounds = false;

            for batchIndex = 1:numberOfBatches
                overview = overviews{batchIndex};
                currentIDs = string(overview.Properties.RowNames);
                [isPresent, rowOrder] = ismember(reactionIDs, currentIDs);

                if ~all(isPresent) || numel(currentIDs) ~= numberOfReactions
                    error( ...
                        "OpenMebius2:ResultRangePlot:ReactionMismatch", ...
                    "Selected results do not contain the same reactions.");
                end

                overview = overview(rowOrder, :);
                lower = double(overview.LB);
                upper = double(overview.UB);
                fvaLower = double(overview.("LB (FVA)"));
                fvaUpper = double(overview.("UB (FVA)"));
                requiresFallback = ~isfinite(lower) | ~isfinite(upper);
                canUseFallback = requiresFallback & ...
                    isfinite(fvaLower) & isfinite(fvaUpper);

                lower(canUseFallback) = fvaLower(canUseFallback);
                upper(canUseFallback) = fvaUpper(canUseFallback);
                usedFvaBounds = usedFvaBounds || any(canUseFallback);

                lowerBounds(:, batchIndex) = lower;
                upperBounds(:, batchIndex) = upper;
                bestFits(:, batchIndex) = double(overview.Flux);
            end

            validRows = all( ...
                isfinite(lowerBounds) & isfinite(upperBounds), 2);

            if ~any(validRows)
                error( ...
                    "OpenMebius2:ResultRangePlot:DataUnavailable", ...
                    "No finite confidence or FVA bounds are available " + ...
                "for the selected results.");
            end

            if any( ...
                    lowerBounds(validRows, :) > ...
                    upperBounds(validRows, :), "all")
                error( ...
                    "OpenMebius2:ResultRangePlot:InvalidBounds", ...
                    "A result contains a lower bound greater than its " + ...
                "upper bound.");
            end

            excludedCount = sum(~validRows);
            reactionIDs = reactionIDs(validRows);
            lowerBounds = lowerBounds(validRows, :);
            upperBounds = upperBounds(validRows, :);
            bestFits = bestFits(validRows, :);
            reactionNames = openmebius.application.result ...
                .ResultRangePlotService.reactionLabels( ...
                overviews{1}, validRows, reactionIDs);
            seriesNames = openmebius.application.result ...
                .ResultRangePlotService.uniqueSeriesNames(batchNames);

            lowerTable = array2table( ...
                lowerBounds, ...
                'VariableNames', cellstr(seriesNames), ...
                'RowNames', cellstr(reactionIDs));
            upperTable = array2table( ...
                upperBounds, ...
                'VariableNames', cellstr(seriesNames), ...
                'RowNames', cellstr(reactionIDs));

            messages = strings(0, 1);

            if usedFvaBounds
                messages(end + 1, 1) = ...
                    "FVA bounds were used where confidence intervals " + ...
                    "were unavailable.";
            end

            if excludedCount > 0
                messages(end + 1, 1) = sprintf( ...
                    "%d reactions without finite bounds were excluded.", ...
                    excludedCount);
            end

            if all(isfinite(bestFits), "all")
                bestFitTable = array2table( ...
                    bestFits, ...
                    'VariableNames', cellstr(seriesNames), ...
                    'RowNames', cellstr(reactionIDs));
            else
                bestFitTable = table();
                messages(end + 1, 1) = ...
                    "Best-fit markers were omitted because some values " + ...
                    "were unavailable.";
            end

            plotResult = openmebius.application.result ...
                .ResultRangePlotResult( ...
                UpperBounds = upperTable, ...
                LowerBounds = lowerTable, ...
                BestFits = bestFitTable, ...
                ReactionNames = reactionNames, ...
                Messages = messages);

        end % prepare

    end % methods

    methods (Static, Access = private)

        function validateSelection(batchIDs, batchNames)

            if isempty(batchIDs)
                error( ...
                    "OpenMebius2:ResultRangePlot:SelectionRequired", ...
                "Please select at least one result to plot ranges.");
            end

            if numel(batchIDs) ~= numel(batchNames)
                error( ...
                    "OpenMebius2:ResultRangePlot:SelectionMismatch", ...
                "Selected result IDs and names do not match.");
            end

            if numel(unique(batchIDs)) ~= numel(batchIDs)
                error( ...
                    "OpenMebius2:ResultRangePlot:DuplicateSelection", ...
                "Each selected result must be unique.");
            end

        end % validateSelection

        function validateResult(result)

            if isempty(result)
                error( ...
                    "OpenMebius2:ResultRangePlot:ResultUnavailable", ...
                "Result data is not available.");
            end

            if isa(result, "handle") && ~isvalid(result)
                error( ...
                    "OpenMebius2:ResultRangePlot:ResultUnavailable", ...
                "Result data is not available.");
            end

        end % validateResult

        function validateOverview(overview, batchID)

            requiredVariables = [ ...
                                     "Reaction", "Flux", "LB", "UB", ...
                                     "LB (FVA)", "UB (FVA)"];

            if ~istable(overview) || isempty(overview) || ...
                    ~all(ismember( ...
                    requiredVariables, ...
                    string(overview.Properties.VariableNames))) || ...
                    isempty(overview.Properties.RowNames)
                error( ...
                    "OpenMebius2:ResultRangePlot:DataUnavailable", ...
                    "Flux range data is unavailable for result '%s'.", ...
                    batchID);
            end

            reactionIDs = string(overview.Properties.RowNames);

            if numel(unique(reactionIDs)) ~= height(overview) || ...
                    any(strlength(reactionIDs) == 0)
                error( ...
                    "OpenMebius2:ResultRangePlot:InvalidData", ...
                "Flux range data contains invalid reaction IDs.");
            end

        end % validateOverview

        function labels = reactionLabels(overview, validRows, reactionIDs)

            reactionNames = string(overview.Reaction(validRows));
            reactionNames = reactionNames(:);
            labels = reactionIDs;
            hasName = strlength(strtrim(reactionNames)) > 0;
            labels(hasName) = reactionIDs(hasName) + ...
                " : " + reactionNames(hasName);

        end % reactionLabels

        function names = uniqueSeriesNames(batchNames)

            names = string(matlab.lang.makeUniqueStrings( ...
                cellstr(batchNames(:)')));
            names = names(:)';

        end % uniqueSeriesNames

    end % methods (Static, Access = private)

end % classdef
