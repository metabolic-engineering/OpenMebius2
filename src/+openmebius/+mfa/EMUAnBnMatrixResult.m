classdef EMUAnBnMatrixResult
    % EMUANBNMATRIXRESULT Immutable An/Bn matrix construction result.

    properties (SetAccess = private)
        An
        Bn
        AnNames cell
        AnMetabolites cell
        BnNames cell
        BnMetabolites cell
        AnList double
        BnList double
    end

    methods

        function obj = EMUAnBnMatrixResult(options)

            arguments
                options.An double
                options.Bn double
                options.AnNames cell
                options.AnMetabolites cell
                options.BnNames cell
                options.BnMetabolites cell
                options.AnList double
                options.BnList double
            end

            obj.An = options.An;
            obj.Bn = options.Bn;
            obj.AnNames = options.AnNames;
            obj.AnMetabolites = options.AnMetabolites;
            obj.BnNames = options.BnNames;
            obj.BnMetabolites = options.BnMetabolites;
            obj.AnList = options.AnList;
            obj.BnList = options.BnList;

        end % constructor

    end % methods

end % classdef
