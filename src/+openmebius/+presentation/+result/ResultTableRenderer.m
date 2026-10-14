classdef ResultTableRenderer
    methods (Static)
        function updateIndexData(tableObject, displayData, rawData)
            previous = tableObject.UserData;
            sameRows = isstruct(previous) && isfield(previous, 'RawData') && ...
                istable(previous.RawData) && istable(rawData) && ...
                isequal(previous.RawData.Properties.VariableNames, rawData.Properties.VariableNames) && ...
                all(ismember({'ID', 'Name', 'RSS'}, rawData.Properties.VariableNames)) && ...
                isequal(previous.RawData.ID, rawData.ID) && ...
                istable(tableObject.Data) && isequal(size(tableObject.Data), size(displayData));
            if sameRows
                old = previous.RawData;
                changed = old.Name ~= rawData.Name | ...
                    ~(old.RSS == rawData.RSS | (isnan(old.RSS) & isnan(rawData.RSS)));
                if any(changed)
                    tableObject.Data(changed, :) = displayData(changed, :);
                end
            elseif ~isequaln(tableObject.Data, displayData)
                tableObject.Data = displayData;
            end
            tableObject.UserData = struct('RawData', rawData);
        end

        function batchStyles(tableObject, rules, styleFactory)
            removeStyle(tableObject);
            if isempty(rules)
                return
            end
            keys = string({rules.StyleKey});
            for key = unique(keys, 'stable')
                selected = rules(keys == key);
                cells = [[selected.Rows]', [selected.Columns]'];
                addStyle(tableObject, styleFactory(key), 'cell', cells);
            end
        end

        function resultStyles(tableObject, rules, styleFactory, theme)
            previous = getappdata(tableObject, 'OpenMebiusResultStyles');
            if ~isempty(previous) && isequaln(previous.Rules, rules) && ...
                    isequal(previous.Theme, theme) && ...
                    height(tableObject.StyleConfigurations) == previous.Count
                return
            end
            removeStyle(tableObject);
            keys = strings(1, numel(rules));
            for index = 1:numel(rules)
                keys(index) = jsonencode([string(rules(index).Target), ...
                    string(rules(index).StyleKey), string(rules(index).Value)]);
            end
            for key = unique(keys, 'stable')
                selected = rules(keys == key);
                target = string(selected(1).Target);
                style = styleFactory(selected(1));
                if target == "cell"
                    cells = [[selected.Rows]', [selected.Columns]'];
                    addStyle(tableObject, style, 'cell', cells);
                elseif target == "row"
                    addStyle(tableObject, style, 'row', [selected.Rows]);
                elseif target == "column"
                    addStyle(tableObject, style, 'column', [selected.Columns]);
                end
            end
            setappdata(tableObject, 'OpenMebiusResultStyles', struct( ...
                'Rules', rules, 'Theme', theme, 'Count', height(tableObject.StyleConfigurations)));
        end
    end
end
