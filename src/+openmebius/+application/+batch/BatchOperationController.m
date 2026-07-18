classdef BatchOperationController < handle
    % BATCHOPERATIONCONTROLLER Runs batch-management commands.

    methods

        function outcome = autoFill(~, batch)

            outcome = openmebius.application.batch ...
                .BatchOperationController.executeCommand( ...
                    @() batch.autoFillBatch());

        end % autoFill

        function outcome = save(~, batch, tableData)

            arguments
                ~
                batch
                tableData table
            end

            outcome = openmebius.application.batch ...
                .BatchOperationController.executeCommand(@saveBatch);

            function saveBatch()

                batch.updateBatchFromGUI(tableData);
                batch.saveBatchFile();

            end

        end % save

        function outcome = remove(~, batch, batchIds)

            arguments
                ~
                batch
                batchIds (:, 1) string
            end

            outcome = openmebius.application.batch ...
                .BatchOperationController.executeCommand(@removeBatches);

            function removeBatches()

                for batchIndex = 1:numel(batchIds)
                    batch.removeBatch(batchIds(batchIndex));
                end

            end

        end % remove

    end % methods

    methods (Static, Access = private)

        function outcome = executeCommand(command)

            try
                command();
                outcome = openmebius.application.batch ...
                    .BatchOperationOutcome("finished");
            catch exception
                outcome = openmebius.application.batch ...
                    .BatchOperationOutcome( ...
                        "error", ...
                        ErrorMessage = string(exception.message), ...
                        Exception = exception);
            end

        end % executeCommand

    end % methods (Static, Access = private)

end % classdef
