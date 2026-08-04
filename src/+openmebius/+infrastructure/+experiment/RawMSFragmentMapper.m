classdef RawMSFragmentMapper
    % RAWMSFRAGMENTMAPPER Maps raw peak rows to an MS workbook table.

    methods

        function msTable = map(~, data, fragmentNames)

            arguments
                ~
                data table
                fragmentNames (:, 1) string
            end

            msTable = table();

            for fragmentIndex = 1:numel(fragmentNames)
                fragment = fragmentNames(fragmentIndex);
                rows = openmebius.infrastructure.experiment ...
                    .RawMSFragmentMapper.matchRows(data.Name, fragment);
                selected = data(rows, "Area");
                rowCount = max(100, height(selected));
                selected = [ ...
                                selected
                            table( ...
                                nan(rowCount - height(selected), 1), ...
                                VariableNames = "Area")]; %#ok<AGROW>

                if sum(selected.Area, "omitnan") <= 0
                    continue
                end

                selected.Properties.VariableNames = fragment;
                msTable = [msTable, selected]; %#ok<AGROW>
            end

            if width(msTable) == 0
                error( ...
                    "OpenMebius2:RawMSFragmentMapper:NoMatchingFragments", ...
                "No matching MS fragment data was found in the raw text file.");
            end

            msTable = msTable(~all(isnan(msTable.Variables), 2), :);

            if isempty(msTable)
                error( ...
                    "OpenMebius2:RawMSFragmentMapper:NoNonzeroData", ...
                "No non-zero MS fragment data was found in the raw text file.");
            end

            msTable.Properties.RowNames = cellstr( ...
                "M+" + string((0:(height(msTable) - 1)).'));

        end

    end

    methods (Static, Access = private)

        function rows = matchRows(names, fragment)
            names = openmebius.infrastructure.experiment ...
                .RawMSFragmentMapper.normalizeLabels(names);
            fragment = openmebius.infrastructure.experiment ...
                .RawMSFragmentMapper.normalizeLabels(fragment);
            rows = startsWith(names, fragment);

            if ~any(rows)
                rows = contains(names, fragment);
            end

        end

        function labels = normalizeLabels(labels)
            labels = lower(string(labels));
            labels = regexprep(labels, '\[m[-_ ]*(\d+)\]', '$1');
            labels = regexprep( ...
                labels, ...
                '(^|[^a-z0-9])m[-_ ]*(\d+)(?=$|[^a-z0-9])', ...
            '$1$2');
            labels = regexprep(labels, '[^a-z0-9]', '');
        end

    end

end
