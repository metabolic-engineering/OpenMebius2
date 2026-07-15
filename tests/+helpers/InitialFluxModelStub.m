classdef InitialFluxModelStub

    methods

        function stoichiometry = getS(~)

            stoichiometry = array2table( ...
                eye(2), ...
                VariableNames = {'v1', 'v2'}, ...
                RowNames = {'balance', 'v2'});

        end

        function systemType = getSType(~)

            systemType = ["dependent"; "independent"];

        end

    end

end
