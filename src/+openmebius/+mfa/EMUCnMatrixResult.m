classdef EMUCnMatrixResult
    % EMUCNMATRIXRESULT Immutable Cn matrix construction result.

    properties (SetAccess = private)
        Matrix
        Diagonal
    end

    methods

        function obj = EMUCnMatrixResult(matrix, diagonal)

            arguments
                matrix logical
                diagonal double
            end

            obj.Matrix = matrix;
            obj.Diagonal = diagonal;

        end % constructor

    end % methods

end % classdef
