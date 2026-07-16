classdef MFAObjectiveStub

    properties (SetAccess = private)
        Target (:, 1) double
    end

    methods

        function obj = MFAObjectiveStub(target)

            obj.Target = target(:);

        end

        function value = evaluate(obj, independentValues)

            value = sum((independentValues - obj.Target) .^ 2);

        end

        function mdv = predictFlux(~, flux)

            mdv = 2 * flux;

        end

    end

end
