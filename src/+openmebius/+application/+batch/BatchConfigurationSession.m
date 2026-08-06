classdef BatchConfigurationSession < handle
    % BATCHCONFIGURATIONSESSION Owns one RunConfig editing session.

    properties (SetAccess = private)
        BatchIds (:, 1) string
    end

    properties (Access = private)
        BatchSource
        Experiments
    end

    methods

        function obj = BatchConfigurationSession( ...
                batchSource, experiments, batchIds)

            arguments
                batchSource
                experiments
                batchIds string
            end

            batchIds = string(batchIds(:));

            if isempty(batchIds) || any(strlength(batchIds) == 0)
                error( ...
                    "OpenMebius2:BatchConfigurationSession:InvalidBatchIds", ...
                "At least one nonempty batch ID is required.");
            end

            if numel(unique(batchIds, "stable")) ~= numel(batchIds)
                error( ...
                    "OpenMebius2:BatchConfigurationSession:DuplicateBatchIds", ...
                "Batch configuration selection contains duplicate IDs.");
            end

            obj.BatchSource = batchSource;
            obj.Experiments = experiments;
            obj.BatchIds = batchIds;

            % Resolve every ID now so a stale selection cannot open an
            % editor that fails only after the user presses Apply.
            obj.configs();

        end % constructor

        function configs = configs(obj)

            configs = repmat( ...
                obj.BatchSource.getBatchConfig(obj.BatchIds(1)), ...
                numel(obj.BatchIds), ...
                1);

            for batchIndex = 2:numel(obj.BatchIds)
                configs(batchIndex) = obj.BatchSource ...
                    .getBatchConfig(obj.BatchIds(batchIndex));
            end

        end % configs

        function config = primaryConfig(obj)

            config = obj.BatchSource.getBatchConfig(obj.BatchIds(1));

        end % primaryConfig

        function tf = isSingleBatch(obj)

            tf = isscalar(obj.BatchIds);

        end % isSingleBatch

        function tf = isReadOnly(obj)

            configs = obj.configs();
            tf = false;

            for batchIndex = 1:numel(configs)
                tf = tf || openmebius.domain.batch.BatchConfig ...
                    .isTerminalStatus(configs(batchIndex).status);
            end

        end % isReadOnly

        function selections = msFragmentSelections(obj)

            selections = obj.BatchSource ...
                .getBatchMSFragmentSelections(obj.BatchIds.');

        end % msFragmentSelections

        function [tableData, editable] = effluxTable(obj)

            [tableData, editable] = obj.BatchSource ...
                .getBatchEffluxSDTable(obj.BatchIds(1).');

        end % effluxTable

        function tableData = gridReactionTable(obj)

            tableData = obj.BatchSource ...
                .getBatchGridReactionTable(obj.BatchIds(1).');

        end % gridReactionTable

        function tableData = suggestionTable(obj)

            tableData = obj.BatchSource ...
                .getBatchSuggestionTable(obj.BatchIds.');

        end % suggestionTable

        function tableData = instPoolTable(obj)

            tableData = obj.BatchSource ...
                .getBatchINSTMFAPoolTable(obj.BatchIds(1).');

        end % instPoolTable

        function [tableData, editable] = instTimePointTable(obj)

            [tableData, editable] = obj.BatchSource ...
                .getBatchINSTMFATimePoints(obj.BatchIds(1).');

        end % instTimePointTable

        function names = experimentNames(obj)

            if isempty(obj.Experiments)
                names = strings(0, 1);
                return
            end

            names = string(getExpList(obj.Experiments));
            names = names(:);

        end % experimentNames

        function outcome = loadTracerConfiguration( ...
                obj, controller, position)

            outcome = controller.loadTracerConfiguration( ...
                obj.Experiments, position);

        end % loadTracerConfiguration

        function apply(obj, config, fragmentSelections, suggestionTable)

            arguments
                obj (1, 1) openmebius.application.batch ...
                    .BatchConfigurationSession
                config (1, 1) struct
                fragmentSelections (1, :) struct
                suggestionTable = []
            end

            if obj.isReadOnly()
                error( ...
                    "OpenMebius2:BatchConfigurationSession:ReadOnly", ...
                "Finished or failed batch configuration is read-only.");
            end

            originalConfigs = obj.configs();

            try
                obj.BatchSource.updateBatchConfig(obj.BatchIds, config);
                obj.BatchSource.updateBatchMSFragmentSelections( ...
                    fragmentSelections);

                if istable(suggestionTable)
                    obj.BatchSource.updateBatchConfigSuggestionTable( ...
                        obj.BatchIds.', suggestionTable);
                end

            catch exception
                exception = obj.rollbackConfigs( ...
                    originalConfigs, exception);
                rethrow(exception);
            end

        end % apply

    end % methods

    methods (Access = private)

        function exception = rollbackConfigs( ...
                obj, originalConfigs, exception)

            try

                for batchIndex = 1:numel(obj.BatchIds)
                    obj.BatchSource.updateBatchConfig( ...
                        obj.BatchIds(batchIndex), ...
                        originalConfigs(batchIndex));
                end

            catch rollbackException
                exception = addCause(exception, rollbackException);
            end

        end % rollbackConfigs

    end % methods (Access = private)

end % classdef
