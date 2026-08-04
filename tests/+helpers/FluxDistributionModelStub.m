classdef FluxDistributionModelStub

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

        function value = getModelTable(~)

            value = table;

        end

        function value = getModelTableRev(~)

            value = table;

        end

        function value = getIdxRev(~)

            value = zeros(0, 2);

        end

        function value = getDOF(~)

            value = 0;

        end

        function value = getSplittedFlux(~, flux)

            value = flux;

        end

    end

end
