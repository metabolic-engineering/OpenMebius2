classdef ModelReactionParser
    % MODELREACTIONPARSER Parses reaction strings without workspace state.

    methods

        function result = parse(~, reactions)

            rowCount = size(reactions, 1);
            reactants = cell(rowCount, 1);
            products = cell(rowCount, 1);
            reversible = false(rowCount, 1);
            errorRows = zeros(1, 0);
            errors = strings(0, 1);

            for row = 1:rowCount
                [expression, isText] = ...
                    openmebius.application.model.ModelReactionParser ...
                    .textAt(reactions, row);

                if ~isText || ismissing(expression) || strtrim(expression) == ""
                    errorRows(end + 1) = row; %#ok<AGROW>
                    errors(end + 1, 1) = ...
                        "Reaction format mismatch at row " + row + ...
                        ": an expression is required."; %#ok<AGROW>
                    continue
                end

                expression = strtrim(expression);
                forwardCount = count(expression, "-->");
                reverseCount = count(expression, "<=>");

                if forwardCount + reverseCount ~= 1
                    errorRows(end + 1) = row; %#ok<AGROW>

                    if forwardCount + reverseCount == 0
                        detail = "exactly one '-->' or '<=>' arrow is required";
                    else
                        detail = "more than one arrow was found";
                    end

                    errors(end + 1, 1) = ...
                        "Reaction format mismatch at row " + row + ...
                        ": " + detail + "."; %#ok<AGROW>
                    continue
                end

                reversible(row) = reverseCount == 1;

                if reversible(row)
                    sides = split(expression, "<=>");
                else
                    sides = split(expression, "-->");
                end

                left = strtrim(split(sides(1), "+"));
                right = strtrim(split(sides(2), "+"));

                if any(left == "") || any(right == "")
                    errorRows(end + 1) = row; %#ok<AGROW>
                    errors(end + 1, 1) = ...
                        "Reaction format mismatch at row " + row + ...
                        ": reactants and products must not be empty."; %#ok<AGROW>
                    reversible(row) = false;
                    continue
                end

                reactants{row} = cellstr(left).';
                products{row} = cellstr(right).';
            end

            result = struct( ...
                Reactants = {reactants}, ...
                Products = {products}, ...
                Reversible = reversible, ...
                ErrorRows = errorRows, ...
                Errors = errors);

        end

    end

    methods (Static, Access = private)

        function [value, isText] = textAt(values, row)

            value = "";
            isText = false;

            try

                if iscell(values)
                    raw = values{row};
                else
                    raw = values(row);
                end

                if ischar(raw) || (isstring(raw) && isscalar(raw))
                    value = string(raw);
                    isText = true;
                end

            catch
                isText = false;
            end

        end % textAt

    end

end
