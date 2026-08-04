classdef MonteCarloIterationStub < handle

    properties (SetAccess = private)
        Fluxes (:, :) double
        ObjectiveValues (1, :) double
        CallCount (1, 1) double = 0
    end

    methods

        function obj = MonteCarloIterationStub(fluxes, objectiveValues)

            if size(fluxes, 2) ~= numel(objectiveValues)
                error("Flux and objective counts must match.");
            end

            obj.Fluxes = fluxes;
            obj.ObjectiveValues = objectiveValues;

        end

        function result = run(obj, mdv)

            obj.CallCount = obj.CallCount + 1;
            index = min(obj.CallCount, size(obj.Fluxes, 2));
            flux = obj.Fluxes(:, index);
            result = openmebius.mfa.MFAIterationResult( ...
                IndependentValues = flux, ...
                Flux = flux, ...
                MDV = mdv, ...
                ObjectiveValue = obj.ObjectiveValues(index), ...
                ExitFlag = 1);

        end

    end

end
