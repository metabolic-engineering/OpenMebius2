classdef ModelWorkspaceValidator
    % MODELWORKSPACEVALIDATOR Validates editable model workspace tables.

    methods

        function validateLabelConfiguration(~, labelTable, ratioTables)
            required = ["Name", "Num"];

            if ~all(ismember(required, string(labelTable.Properties.VariableNames)))
                error( ...
                    "OpenMebius2:LabelConfiguration:InvalidLabelTable", ...
                "Label settings must contain Name and Num columns.");
            end

            fields = fieldnames(ratioTables);

            if numel(fields) ~= height(labelTable)
                error( ...
                    "OpenMebius2:LabelConfiguration:RatioCountMismatch", ...
                "A ratio table is required for each label configuration row.");
            end

            for fieldIndex = 1:numel(fields)
                value = ratioTables.(fields{fieldIndex});

                if ~istable(value) || ~all(ismember( ...
                        ["Label", "Ratio"], ...
                        string(value.Properties.VariableNames)))
                    error( ...
                        "OpenMebius2:LabelConfiguration:InvalidRatioTable", ...
                    "Each ratio setting must contain Label and Ratio columns.");
                end

            end

        end

        function [isValid, errorRows] = validateAtomTable(~, atomTable)
            errors = false(size(atomTable));

            for row = 1:height(atomTable)

                for column = 1:width(atomTable)
                    value = atomTable{row, column};
                    errors(row, column) = ...
                        ~isnumeric(value) || ~isinteger(value) || value < 0;
                end

            end

            errorRows = find(any(errors, 2));
            isValid = ~any(errors, "all");
        end

    end

end
