classdef EMUMDVIndexResult
    % EMUMDVINDEXRESULT Immutable MDV vector index construction result.

    properties (SetAccess = private)
        Info
        Size (1, 1) double
        List
    end

    methods

        function obj = EMUMDVIndexResult(info, size, list)

            arguments
                info double
                size (1, 1) double
                list double
            end

            obj.Info = info;
            obj.Size = size;
            obj.List = list;

        end % constructor

    end % methods

end % classdef
