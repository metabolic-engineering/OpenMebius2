classdef MSViewExperimentsStub < handle

    properties
        HasCalculatedMDV (1, 1) logical = false
        Raw table
        Normalized table
        MDV table
        Biomass table
        Enrichment table
        MDVErrors (1, :) logical = [false, true]
        EnrichmentErrors logical = [false, true; true, false]
    end

    methods

        function obj = MSViewExperimentsStub()

            obj.Raw = obj.dataTable(1);
            obj.Normalized = obj.dataTable(2);
            obj.MDV = obj.dataTable(3);
            obj.Biomass = obj.dataTable(4);
            obj.Enrichment = obj.dataTable(5);

        end

        function names = getExpList(~)
            names = ["Experiment A", "Experiment B"];
        end

        function value = hasCalculatedMDV(obj)
            value = obj.HasCalculatedMDV;
        end

        function value = getMSTable(obj, ~)
            value = obj.Raw;
        end

        function value = getMSNormalizedTable(obj, ~)
            value = obj.Normalized;
        end

        function value = getMDVTable(obj, ~)
            value = obj.MDV;
        end

        function [value, errors] = getMDVBiomassTable(obj, ~)
            value = obj.Biomass;
            errors = obj.MDVErrors;
        end

        function [value, errors] = getEnrichmentComparison(obj)
            value = obj.Enrichment;
            errors = obj.EnrichmentErrors;
        end

    end

    methods (Static, Access = private)

        function value = dataTable(offset)

            value = array2table( ...
                offset + [0, 1; 2, 3], ...
                'VariableNames', {'A', 'B'}, ...
                'RowNames', {'first', 'second'});

        end

    end

end
