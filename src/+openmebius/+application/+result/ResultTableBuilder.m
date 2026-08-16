classdef ResultTableBuilder
    % RESULTTABLEBUILDER Converts persisted result data into display tables.

    methods

        function [value, message] = fluxOverview(~, data, options)

            arguments
                ~
                data struct
                options.Relative (1, 1) logical = false
                options.RelativeTo (1, 1) string = ""
            end

            value = table( ...
                'Size', [0, 6], ...
                'VariableNames', [ ...
                "Reaction", "Flux", "UB", "LB", ...
                "UB (FVA)", "LB (FVA)"], ...
                'VariableTypes', [ ...
                "string", "double", "double", "double", ...
                "double", "double"]);
            message = "";
            status = data.status;

            if status(1)
                fluxVariability = data.fluxVariability;
                reactionIDs = [data.model.modelID; "biomass"];
                reactionNames = [data.model.modelReaction; ""];
                numberOfFluxes = size(fluxVariability.fluxUBFwd, 1);
                value = table( ...
                    'Size', [numberOfFluxes, 6], ...
                    'VariableNames', [ ...
                    "Reaction", "Flux", "LB", "UB", ...
                    "LB (FVA)", "UB (FVA)"], ...
                    'VariableTypes', [ ...
                    "string", "double", "double", "double", ...
                    "double", "double"]);
                value{:, 2:end} = nan(numberOfFluxes, 5);
                value.Properties.RowNames = reactionIDs;
                value.Reaction = reactionNames;
                value.("UB (FVA)") = fluxVariability.fluxUBFwd;
                value.("LB (FVA)") = fluxVariability.fluxLBFwd;
            end

            if status(2)
                fieldName = "fluxResult" + ...
                    string(sprintf("%04d", data.RSSIdx(1)));
                value.Flux = data.(fieldName).fluxFwd;
            end

            if status(3) && ~isempty(data.fluxLB) && ~isempty(data.fluxUB)
                value.LB = data.fluxLB;
                value.UB = data.fluxUB;
            end

            if ~options.Relative || ~status(2)
                return
            end

            reactionIndex = find(contains( ...
                value.Properties.RowNames, options.RelativeTo), 1);

            if isempty(reactionIndex)
                reference = 0.01;
            else
                reference = value.Flux(reactionIndex) / 100;
            end

            if isnan(reference) || reference == 0
                message = "Relative flux cannot be calculated. " + ...
                    "The reference flux is zero or NaN.";
                return
            end

            variables = ["Flux", "LB", "UB", "LB (FVA)", "UB (FVA)"];

            for variable = variables
                value.(variable) = value.(variable) ./ reference;
            end

        end

        function [value, message] = fluxDetailed(~, data)
            value = table( ...
                'Size', [0, 5], ...
                'VariableNames', [ ...
                "Fragment", "M+i", "Measured", ...
                "Estimated", "Chi^2"], ...
                'VariableTypes', [ ...
                "string", "string", "double", "double", "double"]);
            message = "";

            if ~isfield(data, 'RSSIdx') || isempty(data.RSSIdx)
                message = "No flux data found in the result file.";
                return
            end

            fieldName = "fluxResult" + ...
                string(sprintf("%04d", data.RSSIdx(1)));
            mdv = data.(fieldName).MDV;
            numberOfLabelings = size(mdv, 2);
            variableNames = [ ...
                "Fragment", "M+i", ...
                repmat(["Measured", "Estimated", "Chi^2"], ...
                1, numberOfLabelings)];
            variableTypes = [ ...
                "string", "string", ...
                repmat(["double", "double", "double"], ...
                1, numberOfLabelings)];
            value = table( ...
                'Size', [size(mdv, 1), numel(variableNames)], ...
                'VariableNames', variableNames, ...
                'VariableTypes', variableTypes);
            value{:, 1:2} = strings(size(mdv, 1), 2);
            value{:, 3:end} = nan(size(mdv, 1), numberOfLabelings * 3);

            fragmentNames = strings(size(mdv, 1), 1);
            isotopeNames = strings(size(mdv, 1), 1);
            measured = data.MDVExp;
            measuredNames = string(data.MDVExpName);
            fragmentMask = data.MDVFragMask;

            for labelingIndex = 1:numberOfLabelings
                estimatedColumn = labelingIndex * 3 + 1;
                measuredColumn = labelingIndex * 3;
                chiSquareColumn = labelingIndex * 3 + 2;
                value{:, measuredColumn} = measured(:, labelingIndex);
                value{:, estimatedColumn} = mdv(:, labelingIndex);
                difference = ...
                    (mdv(:, labelingIndex) - measured(:, labelingIndex)) ...
                    ./ 0.01;
                chiSquare = difference .^ 2;
                mask = logical(fragmentMask(:, labelingIndex));
                value{mask, chiSquareColumn} = chiSquare(mask);
            end

            isotopeCounter = 0;

            for rowIndex = 1:size(mdv, 1)
                isNewFragment = rowIndex == 1 || ...
                    measuredNames(rowIndex - 1) ~= measuredNames(rowIndex);

                if isNewFragment
                    fragmentNames(rowIndex) = measuredNames(rowIndex);
                    isotopeCounter = 0;
                end

                isotopeNames(rowIndex) = "M + " + string(isotopeCounter);
                isotopeCounter = isotopeCounter + 1;
            end

            value{:, 1} = fragmentNames;
            value{:, 2} = isotopeNames;
        end

        function [value, message] = mdvSummary(~, data)

            variableNames = [ ...
                "Metabolite", ...
                "E[MDV_e] - E[MDV_s]", ...
                "W_1(MDV_e, MDV_s)", ...
                "χ^2"];
            value = table( ...
                'Size', [0, numel(variableNames)], ...
                'VariableNames', variableNames, ...
                'VariableTypes', [ ...
                "string", "double", "double", "double"]);
            message = "";

            if ~isfield(data, 'RSSIdx') || isempty(data.RSSIdx)
                message = "No flux data found in the result file.";
                return
            end

            try
                fieldName = "fluxResult" + ...
                    string(sprintf("%04d", data.RSSIdx(1)));
                simulated = double(data.(fieldName).MDV);
                experimental = double(data.MDVExp);
                fragmentNames = string(data.MDVExpName(:));
                fragmentMask = logical(data.MDVFragMask);
                numberOfRows = size(simulated, 1);
                numberOfLabelings = size(simulated, 2);

                if isvector(fragmentMask) && ...
                        numel(fragmentMask) == numberOfRows
                    fragmentMask = repmat( ...
                        fragmentMask(:), 1, numberOfLabelings);
                end

                if ~isequal(size(experimental), size(simulated)) || ...
                        numel(fragmentNames) ~= numberOfRows || ...
                        ~isequal(size(fragmentMask), size(simulated))
                    error("OpenMebius2:Result:InvalidMDVSummary", ...
                        "Invalid MDV summary dimensions.");
                end

                metabolites = unique(fragmentNames, "stable");
                selected = false(size(metabolites));

                for metaboliteIndex = 1:numel(metabolites)
                    rows = fragmentNames == metabolites(metaboliteIndex);
                    selected(metaboliteIndex) = any( ...
                        fragmentMask(rows, :), "all");
                end

                metabolites = metabolites(selected);
                value = table( ...
                    'Size', [numel(metabolites), numel(variableNames)], ...
                    'VariableNames', variableNames, ...
                    'VariableTypes', [ ...
                    "string", "double", "double", "double"]);
                value.Metabolite = metabolites;

                for metaboliteIndex = 1:numel(metabolites)
                    rows = fragmentNames == metabolites(metaboliteIndex);
                    massIndex = (0:(sum(rows) - 1)).';
                    expectationDifference = 0;
                    wassersteinDistance = 0;
                    chiSquare = 0;

                    for labelingIndex = 1:numberOfLabelings
                        activeMask = fragmentMask(rows, labelingIndex);

                        if ~any(activeMask)
                            continue
                        end

                        experimentalMDV = ...
                            experimental(rows, labelingIndex);
                        simulatedMDV = simulated(rows, labelingIndex);
                        expectationDifference = expectationDifference + ...
                            sum(massIndex .* experimentalMDV) - ...
                            sum(massIndex .* simulatedMDV);
                        wassersteinDistance = wassersteinDistance + ...
                            sum(abs(cumsum( ...
                            experimentalMDV - simulatedMDV)));
                        residual = ( ...
                            simulatedMDV(activeMask) - ...
                            experimentalMDV(activeMask)) ./ 0.01;
                        chiSquare = chiSquare + sum(residual .^ 2);
                    end

                    value{metaboliteIndex, 2:4} = [ ...
                        expectationDifference, ...
                        wassersteinDistance, ...
                        chiSquare];
                end

            catch
                value = table( ...
                    'Size', [0, numel(variableNames)], ...
                    'VariableNames', variableNames, ...
                    'VariableTypes', [ ...
                    "string", "double", "double", "double"]);
                message = "MDV summary data is incomplete.";
            end

        end

        function [value, message] = fluxComparison(~, data, names, options)

            arguments
                ~
                data cell
                names (1, :) string
                options.Relative (1, 1) logical = false
                options.RelativeTo (1, 1) string = ""
            end

            message = "";
            numberOfResults = numel(names);

            if numberOfResults ~= numel(data)
                value = table();
                message = "Failed to load the result files.";
                return
            end

            names = openmebius.application.result ...
                .ResultTableBuilder.uniqueNames(names);
            value = table( ...
                'Size', [0, numberOfResults], ...
                'VariableNames', names, ...
                'VariableTypes', repmat("double", 1, numberOfResults));

            for resultIndex = 1:numberOfResults
                item = data{resultIndex};

                if ~isfield(item, 'RSSIdx') || isempty(item.RSSIdx)
                    continue
                end

                fieldName = "fluxResult" + ...
                    string(sprintf("%04d", item.RSSIdx(1)));
                flux = item.(fieldName).fluxFwd;

                if resultIndex == 1
                    value = table( ...
                        'Size', [numel(flux), numberOfResults + 1], ...
                        'VariableNames', ["Reaction", names], ...
                        'VariableTypes', [ ...
                        "string", repmat("double", 1, numberOfResults)], ...
                        'RowNames', [item.model.modelID; "biomass"]);
                    value.Reaction = [item.model.modelReaction; ""];
                end

                value.(names(resultIndex)) = flux;
            end

            if ~options.Relative || numberOfResults <= 1 || isempty(value)
                return
            end

            reactionIndex = find(contains( ...
                value.Properties.RowNames, options.RelativeTo), 1);

            for resultIndex = 1:numberOfResults

                if isempty(reactionIndex)
                    reference = 0.01;
                else
                    reference = ...
                        value.(names(resultIndex))(reactionIndex) / 100;
                end

                value.(names(resultIndex)) = ...
                    value.(names(resultIndex)) ./ reference;
            end

        end

        function [value, message] = gridSearch(~, data)

            value = table();
            message = "";

            if ~isfield(data, "CI") || ...
                    ~isstruct(data.CI) || ...
                    ~isfield(data.CI, "algorithm") || ...
                    string(data.CI.algorithm) ~= "Grid search"
                return
            end

            if ~isfield(data.CI, "gridSearch") || ...
                    ~isstruct(data.CI.gridSearch)
                message = "Grid-search result data is incomplete.";
                return
            end

            try
                gridSearch = data.CI.gridSearch;
                fluxIndices = double(gridSearch.fluxIndices(:));
                reactionIDs = string(gridSearch.reactionIDs(:));
                fixedFlux = double(gridSearch.fixedFlux);
                rss = double(gridSearch.RSS);
                minimumRSS = double(gridSearch.minimumRSS);
                bestObjective = double(gridSearch.bestObjective);
                objectiveThreshold = double( ...
                    gridSearch.objectiveThreshold);
                profileCount = numel(fluxIndices);
                pointCount = size(fixedFlux, 2);
                trialCount = size(rss, 3);

                if profileCount == 0 || ...
                        numel(reactionIDs) ~= profileCount || ...
                        size(fixedFlux, 1) ~= profileCount || ...
                        size(rss, 1) ~= profileCount || ...
                        size(rss, 2) ~= pointCount || ...
                        ~isequal(size(minimumRSS), ...
                        [profileCount, pointCount]) || ...
                        ~isscalar(bestObjective) || ...
                        ~isfinite(bestObjective) || ...
                        ~isscalar(objectiveThreshold) || ...
                        ~isfinite(objectiveThreshold)
                    error("invalid grid-search dimensions");
                end

                modelIDs = [string(data.model.modelID(:)); "biomass"];
                reactionNames = [ ...
                    string(data.model.modelReaction(:)); "biomass"];
                rowCount = profileCount * pointCount * trialCount;
                outputReactionIDs = strings(rowCount, 1);
                outputReactionNames = strings(rowCount, 1);
                outputFluxIndices = zeros(rowCount, 1);
                outputGridPoints = zeros(rowCount, 1);
                outputTrials = zeros(rowCount, 1);
                outputFixedFlux = nan(rowCount, 1);
                outputRSS = nan(rowCount, 1);
                outputMinimumRSS = nan(rowCount, 1);
                cursor = 0;

                for profileIndex = 1:profileCount
                    rows = cursor + (1:(pointCount * trialCount));
                    pointIndices = repelem( ...
                        (1:pointCount).', trialCount);
                    trialIndices = repmat( ...
                        (1:trialCount).', pointCount, 1);
                    reactionName = "";
                    modelIndex = find( ...
                        modelIDs == reactionIDs(profileIndex), 1);

                    if ~isempty(modelIndex)
                        reactionName = reactionNames(modelIndex);
                    end

                    rssMatrix = reshape( ...
                        rss(profileIndex, :, :), ...
                        pointCount, trialCount);
                    outputReactionIDs(rows) = ...
                        reactionIDs(profileIndex);
                    outputReactionNames(rows) = reactionName;
                    outputFluxIndices(rows) = ...
                        fluxIndices(profileIndex);
                    outputGridPoints(rows) = pointIndices;
                    outputTrials(rows) = trialIndices;
                    outputFixedFlux(rows) = repelem( ...
                        fixedFlux(profileIndex, :).', trialCount);
                    outputRSS(rows) = reshape(rssMatrix.', [], 1);
                    outputMinimumRSS(rows) = repelem( ...
                        minimumRSS(profileIndex, :).', trialCount);
                    cursor = cursor + pointCount * trialCount;
                end

                value = table( ...
                    outputReactionIDs, ...
                    outputReactionNames, ...
                    outputFluxIndices, ...
                    outputGridPoints, ...
                    outputTrials, ...
                    outputFixedFlux, ...
                    outputRSS, ...
                    outputMinimumRSS, ...
                    repmat(bestObjective, rowCount, 1), ...
                    repmat(objectiveThreshold, rowCount, 1), ...
                    'VariableNames', { ...
                    'ReactionID', 'Reaction', 'FluxIndex', ...
                    'GridPoint', 'Trial', 'FixedFlux', ...
                    'RSS', 'MinimumRSS', 'BestObjective', ...
                    'ObjectiveThreshold'});

            catch
                value = table();
                message = "Grid-search result data is incomplete.";
            end

        end % gridSearch

        function profiles = gridSearchProfiles(~, gridSearch)

            profiles = repmat( ...
                struct( ...
                "ReactionID", "", ...
                "FluxIndex", NaN, ...
                "Data", table()), ...
                0, 1);

            requiredVariables = [ ...
                "ReactionID", "FluxIndex", "Trial", ...
                "FixedFlux", "MinimumRSS"];

            if isempty(gridSearch) || ~istable(gridSearch) || ...
                    ~all(ismember( ...
                    requiredVariables, ...
                    string(gridSearch.Properties.VariableNames)))
                return
            end

            fluxIndices = unique(gridSearch.FluxIndex, "stable");

            for profileIndex = 1:numel(fluxIndices)
                fluxIndex = fluxIndices(profileIndex);
                rows = gridSearch.FluxIndex == fluxIndex & ...
                    gridSearch.Trial == 1;

                if ~any(rows)
                    continue
                end

                reactionIDs = string(gridSearch.ReactionID(rows));
                rawFixedFlux = double(gridSearch.FixedFlux(rows));
                rawRSS = double(gridSearch.MinimumRSS(rows));
                validFixedFlux = isfinite(rawFixedFlux);
                rawFixedFlux = rawFixedFlux(validFixedFlux);
                rawRSS = rawRSS(validFixedFlux);
                [fixedFlux, ~, groups] = unique( ...
                    rawFixedFlux(:), "sorted");
                rss = nan(size(fixedFlux));

                for groupIndex = 1:numel(fixedFlux)
                    values = rawRSS(groups == groupIndex);
                    values = values(isfinite(values));

                    if ~isempty(values)
                        rss(groupIndex) = min(values);
                    end
                end

                profileData = table( ...
                    fixedFlux, rss, ...
                    'VariableNames', {'FixedFlux', 'RSS'});
                profiles(end + 1, 1) = struct( ... %#ok<AGROW>
                    "ReactionID", reactionIDs(1), ...
                    "FluxIndex", double(fluxIndex), ...
                    "Data", profileData);
            end

        end % gridSearchProfiles

    end

    methods (Static, Access = private)

        function values = uniqueNames(values)
            original = values;

            for valueIndex = 1:numel(values)

                if sum(original == original(valueIndex)) > 1
                    values(valueIndex) = ...
                        original(valueIndex) + "_" + string(valueIndex);
                end

            end

        end

    end

end
