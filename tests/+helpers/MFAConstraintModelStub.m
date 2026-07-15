classdef MFAConstraintModelStub

    properties
        Stoichiometry table
        SystemTypes (:, 1) string = ...
            ["dependent"; "efflux"; "efflux"; "independent"]
    end

    methods

        function obj = MFAConstraintModelStub()

            obj.Stoichiometry = array2table( ...
                zeros(3, 4), ...
                VariableNames = {'v1', 'v2', 'v3', 'v4'}, ...
                RowNames = {'biomass', 'EX_A', 'EX_B'});

        end

        function value = getSBefore(obj)

            value = obj.Stoichiometry;

        end

        function value = getSType(obj)

            value = obj.SystemTypes;

        end

        function value = getSubstrateNameFromRxnID(~, reactionID)

            switch string(reactionID)
                case "EX_A"
                    value = "A";
                case "EX_B"
                    value = "B";
                otherwise
                    value = string.empty(0, 1);
            end

        end

    end

end
