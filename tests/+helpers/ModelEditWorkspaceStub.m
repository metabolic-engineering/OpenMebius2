classdef ModelEditWorkspaceStub < handle

    properties
        ModelReport
        MSReport
        AtomReport
        Exception = []
        ModelCalled (1, 1) logical = false
        MSCalled (1, 1) logical = false
        AtomCalled (1, 1) logical = false
        ModelTable
        MSTable
        AtomTable
    end

    methods

        function report = updateModelTableGUI(obj, tableData)

            obj.ModelCalled = true;
            obj.ModelTable = tableData;
            obj.throwIfNeeded();
            report = obj.ModelReport;

        end

        function report = updateMSTable(obj, tableData)

            obj.MSCalled = true;
            obj.MSTable = tableData;
            obj.throwIfNeeded();
            report = obj.MSReport;

        end

        function report = updateAtomTable(obj, tableData)

            obj.AtomCalled = true;
            obj.AtomTable = tableData;
            obj.throwIfNeeded();
            report = obj.AtomReport;

        end

    end

    methods (Access = private)

        function throwIfNeeded(obj)

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

        end

    end

end
