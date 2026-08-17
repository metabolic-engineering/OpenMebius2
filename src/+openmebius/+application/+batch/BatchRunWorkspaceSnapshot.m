classdef BatchRunWorkspaceSnapshot
    % BATCHRUNWORKSPACESNAPSHOT Latest editable tables captured on Run.

    properties (SetAccess = private)
        InformationTable table
        UptakeTable table
        TracerTable table
        BatchTable table
    end

    methods

        function obj = BatchRunWorkspaceSnapshot(options)

            arguments
                options.InformationTable table
                options.UptakeTable table
                options.TracerTable table
                options.BatchTable table
            end

            obj.InformationTable = options.InformationTable;
            obj.UptakeTable = options.UptakeTable;
            obj.TracerTable = options.TracerTable;
            obj.BatchTable = options.BatchTable;

        end % constructor

    end % methods

end % classdef
