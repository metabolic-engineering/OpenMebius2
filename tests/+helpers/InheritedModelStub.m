classdef InheritedModelStub < helpers.FluxDistributionModelStub
    methods
        function value = getModelTable(~)
            value = table(["A -> B"; "B -> C"], ["a -> a"; "a -> a"], [false; true], ...
                VariableNames = {'Reaction', 'Transition', 'Independent'}, RowNames = {'v1', 'v2'});
        end
        function value = getModelTableRev(obj)
            value = obj.getModelTable();
        end
    end
end
