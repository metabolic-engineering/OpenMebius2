classdef ReportModelStub < handle

    properties
        isError (1, 1) logical = false
    end

    methods

        function value = getInfoTable(~)

            value = table( ...
                ["Name"; "Mode"], ...
                ["Test model"; "Steady state"], ...
                'VariableNames', ["Information", "Value"]);

        end

        function value = getModelTable(~)

            value = table( ...
                "A -> B", ...
                false, ...
                'VariableNames', ["Reaction", "Independent"], ...
                'RowNames', {'R1'});

        end

        function value = getMSTable(~)

            value = table( ...
                "A -> B", ...
                true, ...
                'VariableNames', ["Transition", "Used"], ...
                'RowNames', {'R1'});

        end

        function value = getBiomassTable(~)

            value = table( ...
                "B", ...
                1, ...
                'VariableNames', ["Precursor", "Biomass"]);

        end

        function value = getAtomTable(~)

            value = table( ...
                int8([1; 1]), ...
                'VariableNames', "C", ...
                'RowNames', {'A', 'B'});

        end

        function value = getSBefore(~)

            value = array2table( ...
                [-1; 1], ...
                'VariableNames', "R1", ...
                'RowNames', {'A', 'B'});

        end

    end

end
