classdef ModelWorkspaceTableStub < handle

    properties
        ModelTable table
        MassSpectrometryTable table
        AtomTable table
        BiomassTable table
        InvalidModelRows (:, 1) double = 2
        InvalidMassSpectrometryRows (:, 1) double = 1
        InvalidAtomRows (:, 1) double = 2
    end

    methods

        function obj = ModelWorkspaceTableStub()

            obj.ModelTable = table( ...
                ["R1"; "R2"], ...
                [false; true], ...
                VariableNames = ["Reaction", "Independent"], ...
                RowNames = ["first"; "second"]);
            obj.MassSpectrometryTable = table( ...
                ["R1"; "R2"], ...
                [true; false], ...
                VariableNames = ["Reaction", "Use"], ...
                RowNames = ["first"; "second"]);
            obj.AtomTable = table( ...
                ["A"; "B"], ...
                [1; 2], ...
                VariableNames = ["Metabolite", "Carbon"], ...
                RowNames = ["first"; "second"]);
            obj.BiomassTable = table( ...
                ["A"; "B"], ...
                [0.4; 0.6], ...
                VariableNames = ["Metabolite", "Coefficient"]);

        end

        function value = getModelTableGUI(obj)
            value = obj.ModelTable;
        end

        function value = getMSTable(obj)
            value = obj.MassSpectrometryTable;
        end

        function value = getAtomTable(obj)
            value = obj.AtomTable;
        end

        function value = getBiomassTable(obj)
            value = obj.BiomassTable;
        end

        function value = getInvalidModelRowIdx(obj)
            value = obj.InvalidModelRows;
        end

        function value = getInvalidMSRowIdx(obj)
            value = obj.InvalidMassSpectrometryRows;
        end

        function value = getInvalidAtomRowIdx(obj)
            value = obj.InvalidAtomRows;
        end

        function value = snapshot(obj)
            value = openmebius.domain.model.ModelAggregate( ...
                ModelTable = obj.ModelTable, ...
                MassSpectrometryTable = obj.MassSpectrometryTable, ...
                AtomTable = obj.AtomTable, ...
                BiomassTable = obj.BiomassTable, ...
                InvalidModelRows = obj.InvalidModelRows, ...
                InvalidMassSpectrometryRows = ...
                    obj.InvalidMassSpectrometryRows, ...
                InvalidAtomRows = obj.InvalidAtomRows);
        end

    end

end % classdef
