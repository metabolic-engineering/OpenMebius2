classdef ExperimentAggregateTables
    % EXPERIMENTAGGREGATETABLES Typed result of experiment table assembly.

    properties (SetAccess = private)
        Info table
        Tracer table
        TracerFull table
        Uptake table
        UptakeFull table
    end

    methods

        function obj = ExperimentAggregateTables(options)

            arguments
                options.Info table = table()
                options.Tracer table = table()
                options.TracerFull table = table()
                options.Uptake table = table()
                options.UptakeFull table = table()
            end

            obj.Info = options.Info;
            obj.Tracer = options.Tracer;
            obj.TracerFull = options.TracerFull;
            obj.Uptake = options.Uptake;
            obj.UptakeFull = options.UptakeFull;

        end % constructor

    end % methods

end % classdef
