classdef TracerConfigContext
    % TRACERCONFIGCONTEXT Initial state passed to TracerConfig.

    properties (SetAccess = private)
        EditorTable table
        Position (1, 2) double
    end

    methods

        function obj = TracerConfigContext(options)

            arguments
                options.EditorTable table
                options.Position (1, 2) double { ...
                                                    mustBeInteger, mustBePositive}
            end

            obj.EditorTable = options.EditorTable;
            obj.Position = options.Position;

        end % constructor

    end % methods

end % classdef
