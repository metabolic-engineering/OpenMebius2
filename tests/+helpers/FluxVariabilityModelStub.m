classdef FluxVariabilityModelStub

    properties
        Stoichiometry table
    end

    methods

        function obj = FluxVariabilityModelStub()

            obj.Stoichiometry = array2table( ...
                [1, 2, 3, 4; 5, 6, 7, 8; 9, 10, 11, 12], ...
                VariableNames = {'v1', 'v2', 'v2_rev', 'v3'}, ...
                RowNames = {'biomass', 'EX_A', 'internal'});

        end

        function value = getSBefore(obj)

            value = obj.Stoichiometry;

        end

        function value = getSType(~)

            value = ["dependent"; "efflux"; ...
                "dependent"; "independent"];

        end

        function value = getIdxRev(~)

            value = [2; 3];

        end

        function value = findCounterReaction(~, reactionID)

            if string(reactionID) == "v2_rev"
                value = 2;
            else
                value = [];
            end

        end

        function value = getSubstrateNameFromRxnID(~, reactionID)

            if string(reactionID) == "EX_A"
                value = "A";
            else
                value = string.empty(0, 1);
            end

        end

    end

end
