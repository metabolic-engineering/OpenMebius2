classdef ExperimentWorkbookData
    % EXPERIMENTWORKBOOKDATA Typed persistence data for one workbook.

    properties (SetAccess = private)
        Info table
        Substrate table
        MS table
        MSNormalized table
        MDV table
        MDVBiomass table
        Enrichment table
        DefaultSubstrateVariableNames (1, :) string
        DefaultSubstrateVariableTypes (1, :) string
    end

    methods

        function obj = ExperimentWorkbookData(options)

            arguments
                options.Info table = table()
                options.Substrate table = table()
                options.MS table = table()
                options.MSNormalized table = table()
                options.MDV table = table()
                options.MDVBiomass table = table()
                options.Enrichment table = table()
                options.DefaultSubstrateVariableNames (1, :) string = ...
                    strings(1, 0)
                options.DefaultSubstrateVariableTypes (1, :) string = ...
                    strings(1, 0)
            end

            if numel(options.DefaultSubstrateVariableNames) ~= ...
                    numel(options.DefaultSubstrateVariableTypes)
                error( ...
                    "OpenMebius2:ExperimentWorkbookData:" + ...
                    "DefaultVariableCountMismatch", ...
                    "Default substrate names and types must have " + ...
                    "the same length.");
            end

            obj.Info = options.Info;
            obj.Substrate = options.Substrate;
            obj.MS = options.MS;
            obj.MSNormalized = options.MSNormalized;
            obj.MDV = options.MDV;
            obj.MDVBiomass = options.MDVBiomass;
            obj.Enrichment = options.Enrichment;
            obj.DefaultSubstrateVariableNames = ...
                options.DefaultSubstrateVariableNames;
            obj.DefaultSubstrateVariableTypes = ...
                options.DefaultSubstrateVariableTypes;

        end % constructor

    end % methods

end % classdef
