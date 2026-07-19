classdef EMUXnYnMatrixResult
    % EMUXNYNMATRIXRESULT Immutable Xn/Yn matrix construction result.

    properties (SetAccess = private)
        Xn
        Yn
        XnList double
        YnList double
        HasSubstrates (1, 1) logical
    end

    methods

        function obj = EMUXnYnMatrixResult(options)

            arguments
                options.Xn double
                options.Yn double
                options.XnList double
                options.YnList double
                options.HasSubstrates (1, 1) logical
            end

            obj.Xn = options.Xn;
            obj.Yn = options.Yn;
            obj.XnList = options.XnList;
            obj.YnList = options.YnList;
            obj.HasSubstrates = options.HasSubstrates;

        end % constructor

    end % methods

end % classdef
