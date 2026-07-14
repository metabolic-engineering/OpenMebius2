classdef SteadyStateModelStub < handle

    properties
        ReactionNames (1, :) string = ["R1", "R2"]
        SubstrateReactionIDs (1, :) string = ["R1", "R2"]
    end

    methods

        function mdv = calculateMDV(~, flux, emu)

            mdv = emu * flux;

        end

        function mdv = calculateMDVTimeCourse( ...
                ~, flux, emu, poolSizes, timePoints)

            mdv = (emu * flux) * timePoints(:).' / mean(poolSizes);

        end

        function stoichiometry = getSBefore(obj)

            stoichiometry = array2table( ...
                eye(numel(obj.ReactionNames)), ...
                VariableNames = cellstr(obj.ReactionNames));

        end

        function reactionID = ...
                findSubstrateRxnIDFromMetaboliteIrrev(obj, substrate)

            substrateIndex = sscanf(char(substrate), 'S%d');
            reactionID = obj.SubstrateReactionIDs(substrateIndex);

        end

    end

end
