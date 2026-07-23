classdef GridSearchProfileData

    properties (SetAccess = private)
        FluxIndices (:, 1) double
        FixedFluxValues double
        MinimumSumOfSquares double
    end % properties (SetAccess = private)

    methods

        function obj = GridSearchProfileData(options)

            arguments
                options.FluxIndices (:, 1) double
                options.FixedFluxValues double
                options.MinimumSumOfSquares double
            end

            if ~isequal(size(options.FixedFluxValues), size(options.MinimumSumOfSquares))
                error( ...
                    "OpenMebius2:GridSearchProfileData:InvalidInput", ...
                    "Fixed flux values and minimum sum-of-squares values " + ...
                "must have the same size.");
            end % if

            if size(options.FixedFluxValues, 1) ~= size(options.FluxIndices, 1)
                error( ...
                    "OpenMebius2:GridSearchProfileData:InvalidInput", ...
                    "Fixed flux values and flux indices must have the same " + ...
                "row count.");
            end % if

            if any(options.FluxIndices < 1) || ...
                    any(fix(options.FluxIndices) ~= options.FluxIndices) || ...
                    numel(unique(options.FluxIndices)) ~= ...
                    numel(options.FluxIndices)
                error( ...
                    "OpenMebius2:GridSearchProfile:InvalidFluxIndices", ...
                "Flux indices must be unique positive integers.");
            end

            obj.FluxIndices = fluxIndices;
            obj.FixedFluxValues = fixedFluxValues;
            obj.MinimumSumOfSquares = minimumSumOfSquares;

        end % constructor

    end % methods

end % classdef
