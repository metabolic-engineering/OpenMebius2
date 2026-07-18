classdef TracerPatternCodec
    % TRACERPATTERNCODEC Converts tracer editor values to stored patterns.

    methods (Static)

        function pattern = encode(editorTable)

            arguments
                editorTable table
            end

            requiredColumns = ["Select", "Label", "Ratio"];

            if ~all(ismember( ...
                    requiredColumns, ...
                    string(editorTable.Properties.VariableNames)))
                error( ...
                    "OpenMebius2:TracerConfiguration:InvalidTable", ...
                    "Tracer configuration must contain Select, Label " + ...
                    "and Ratio columns.");
            end

            selectedRows = logical(editorTable.Select);
            selected = editorTable(selectedRows, :);

            if isempty(selected)
                pattern = "";
                return
            end

            if height(selected) == 1
                selected.Ratio = 1;
            else
                selected = selected(selected.Ratio ~= 0, :);
            end

            if isempty(selected)
                pattern = "";
                return
            end

            labels = string(selected.Label);
            ratios = double(selected.Ratio);
            parts = strings(height(selected), 1);

            for row = 1:height(selected)
                parts(row) = string(sprintf( ...
                    "%s~%g", labels(row), ratios(row)));
            end

            pattern = join(parts, ";");

        end % encode

    end % methods (Static)

end % classdef
