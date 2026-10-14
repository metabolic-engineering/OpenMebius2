classdef InheritedBatchConfig
    % Only post-optimization options may change on an inherited batch.
    methods (Static)
        function tf = isInherited(config)
            tf = isfield(config, 'inheritedFrom') && ...
                strlength(string(config.inheritedFrom)) > 0;
        end

        function config = preserveOptimization(current, requested)
            if ~openmebius.domain.batch.InheritedBatchConfig.isInherited(current)
                config = requested;
                return
            end
            config = current;
            fields = {'isCalcCI', 'CIConf', 'suggestNextFlux', ...
                'suggestionTable', 'suggestionTableRowNames', ...
                'suggestionTableVarNames'};
            for index = 1:numel(fields)
                field = fields{index};
                if isfield(requested, field)
                    config.(field) = requested.(field);
                end
            end
        end
    end
end
