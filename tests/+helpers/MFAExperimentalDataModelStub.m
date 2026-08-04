classdef MFAExperimentalDataModelStub

    properties
        FragmentList (:, 1) string = ["A"; "B"]
        FragmentMetadata table
        MSSelection table
    end

    methods

        function obj = MFAExperimentalDataModelStub()

            obj.FragmentMetadata = table( ...
                ["A"; "B"], ...
                {2; 1}, ...
                VariableNames = {'Metabolite', 'Carbon'});
            obj.MSSelection = table( ...
                [true; false], ...
                VariableNames = {'Used'}, ...
                RowNames = {'A', 'B'});

        end

        function value = getTargetMetaboliteList(obj)

            value = obj.FragmentList;

        end

        function value = getMSMetaboliteTable(obj)

            value = obj.FragmentMetadata;

        end

        function value = getMSTable(obj)

            value = obj.MSSelection;

        end

    end

end
