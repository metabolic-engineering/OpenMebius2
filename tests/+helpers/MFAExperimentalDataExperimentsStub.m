classdef MFAExperimentalDataExperimentsStub

    properties
        ExperimentNames (:, 1) string
        MDVTables (:, 1) cell
    end

    methods

        function obj = MFAExperimentalDataExperimentsStub( ...
                experimentNames, mdvTables)

            obj.ExperimentNames = string(experimentNames(:));
            obj.MDVTables = mdvTables(:);

        end

        function value = getMDVBiomassTable(obj, experimentName)

            index = find( ...
                obj.ExperimentNames == string(experimentName), ...
                1, ...
                "first");

            if isempty(index)
                error("Unknown experiment.");
            end

            value = obj.MDVTables{index};

        end

    end

end
