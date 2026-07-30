classdef GridSearchModelStub

    methods

        function value = getModelTable(~)

            value = table( ...
                ["A -> B"; "B -> C"], ...
                VariableNames = "Reaction", ...
                RowNames = {'r1', 'r2'});

        end

        function value = getIdxRev(~)

            value = zeros(0, 2);

        end

        function value = getDOF(~)

            value = 0;

        end

    end

end
