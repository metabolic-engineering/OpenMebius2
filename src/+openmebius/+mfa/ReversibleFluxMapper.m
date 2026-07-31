classdef ReversibleFluxMapper
    % REVERSIBLEFLUXMAPPER
    % Maps split reversible reactions to net forward flux values.

    methods (Static)

        function forwardFlux = mapFlux(flux, reversibleReactionIndices)

            arguments
                flux double
                reversibleReactionIndices (:, 2) double = zeros(0, 2)
            end

            openmebius.mfa.ReversibleFluxMapper.validateIndices( ...
                reversibleReactionIndices, size(flux, 1));
            forwardFlux = flux;

            if isempty(reversibleReactionIndices)
                return;
            end

            forwardIndices = reversibleReactionIndices(:, 1);
            reverseIndices = reversibleReactionIndices(:, 2);
            forwardFlux(forwardIndices, :) = ...
                flux(forwardIndices, :) - flux(reverseIndices, :);
            forwardFlux(reverseIndices, :) = [];

        end % mapFlux

        function [forwardLowerBounds, forwardUpperBounds] = ...
                mapBounds( ...
                lowerBounds, upperBounds, reversibleReactionIndices)

            arguments
                lowerBounds (:, 1) double
                upperBounds (:, 1) double
                reversibleReactionIndices (:, 2) double = zeros(0, 2)
            end

            if size(lowerBounds, 1) ~= size(upperBounds, 1)
                error( ...
                    "OpenMebius2:ReversibleFluxMapper:" + ...
                    "FluxBoundSizeMismatch", ...
                "Lower and upper flux bounds must have the same size.");
            end

            openmebius.mfa.ReversibleFluxMapper.validateIndices( ...
                reversibleReactionIndices, size(lowerBounds, 1));
            forwardLowerBounds = lowerBounds;
            forwardUpperBounds = upperBounds;

            if isempty(reversibleReactionIndices)
                return;
            end

            forwardIndices = reversibleReactionIndices(:, 1);
            reverseIndices = reversibleReactionIndices(:, 2);
            forwardLowerBounds(forwardIndices) = ...
                lowerBounds(forwardIndices) - upperBounds(reverseIndices);
            forwardUpperBounds(forwardIndices) = ...
                upperBounds(forwardIndices) - lowerBounds(reverseIndices);
            forwardLowerBounds(reverseIndices) = [];
            forwardUpperBounds(reverseIndices) = [];

        end % mapBounds

    end % methods (Static)

    methods (Static, Access = private)

        function validateIndices(indices, fluxCount)

            if isempty(indices)
                return;
            end

            if any(~isfinite(indices), "all") || ...
                    any(indices < 1, "all") || ...
                    any(indices ~= fix(indices), "all") || ...
                    any(indices > fluxCount, "all") || ...
                    numel(unique(indices(:, 2))) ~= size(indices, 1)
                error( ...
                    "OpenMebius2:ReversibleFluxMapper:" + ...
                    "InvalidReversibleReactionIndices", ...
                    "Reversible reaction indices must contain valid, " + ...
                "unique flux positions.");
            end

        end % validateIndices

    end % methods (Static, Access = private)

end % classdef
