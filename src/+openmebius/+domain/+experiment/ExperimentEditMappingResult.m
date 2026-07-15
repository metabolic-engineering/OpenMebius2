classdef ExperimentEditMappingResult
    % EXPERIMENTEDITMAPPINGRESULT Complete state produced by an edit mapping.

    properties (SetAccess = private)
        Data
        AggregateTable table
        FullTable table
        Target (1, 1) string
    end

    methods

        function obj = ExperimentEditMappingResult( ...
                data, aggregateTable, fullTable, target)

            arguments
                data
                aggregateTable table
                fullTable table
                target (1, 1) string {mustBeMember( ...
                    target, ["Tracer", "Uptake"])}
            end

            obj.Data = data;
            obj.AggregateTable = aggregateTable;
            obj.FullTable = fullTable;
            obj.Target = target;

        end % constructor

    end % methods

end % classdef
