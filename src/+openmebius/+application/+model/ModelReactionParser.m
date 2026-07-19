classdef ModelReactionParser
    % MODELREACTIONPARSER Parses reaction strings without workspace state.

    methods

        function result = parse(~, reactions)

            arguments
                ~
                reactions cell
            end

            count = size(reactions, 1);
            reactants = cell(count, 1);
            products = cell(count, 1);
            reversible = false(count, 1);
            errorRows = zeros(1, 0);
            errors = strings(0, 1);

            for row = 1:count
                if isempty(reactions(row)) || any(ismissing(reactions(row)))
                    continue
                end

                forward = strsplit(reactions{row}, '-->');
                reverse = strsplit(reactions{row}, '<=>');

                if numel(forward) == 2
                    reactants{row} = strsplit(forward{1}, '+');
                    products{row} = strsplit(forward{2}, '+');
                elseif numel(reverse) == 2
                    reactants{row} = strsplit(reverse{1}, '+');
                    products{row} = strsplit(reverse{2}, '+');
                    reversible(row) = true;
                elseif isscalar(forward) && isscalar(reverse)
                    errorRows(end + 1) = row; %#ok<AGROW>
                    errors(end + 1, 1) = ...
                        "The reaction " + string(reactions{row}) + ...
                        " does not contain an arrow."; %#ok<AGROW>
                else
                    errorRows(end + 1) = row; %#ok<AGROW>
                    errors(end + 1, 1) = ...
                        "The reaction " + string(reactions{row}) + ...
                        " contains more than one arrow."; %#ok<AGROW>
                end
            end

            if ~isempty(errors)
                reactants = cell(count, 1);
                products = cell(count, 1);
                reversible = false(count, 1);
            else
                reactants = strtrim(reactants);
                products = strtrim(products);
            end

            result = struct( ...
                Reactants = {reactants}, ...
                Products = {products}, ...
                Reversible = reversible, ...
                ErrorRows = errorRows, ...
                Errors = errors);

        end

    end

end
