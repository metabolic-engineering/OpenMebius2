classdef BatchOperationController < handle
    % BATCHOPERATIONCONTROLLER Runs batch-management commands.

    properties (SetAccess = private)
        ArtifactRepository
    end

    methods

        function obj = BatchOperationController(options)

            arguments
                options.ArtifactRepository = ...
                    openmebius.infrastructure.result ...
                    .ResultArtifactRepository()
            end

            obj.ArtifactRepository = options.ArtifactRepository;

        end % constructor

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

        function outcome = duplicate(~, batch, batchIds, tableData)

            arguments
                ~
                batch
                batchIds (:, 1) string
                tableData table
            end

            outcome = openmebius.application.batch ...
                .BatchOperationController.executeCommand( ...
                @duplicateBatches);

            function duplicateBatches()

                batch.updateBatchFromGUI(tableData);
                batch.duplicateBatches(batchIds);

            end

        end % duplicate

        function outcome = remove(obj, batch, batchIds, resultLocation)

            arguments
                obj
                batch
                batchIds (:, 1) string
                resultLocation = []
            end

            outcome = openmebius.application.batch ...
                .BatchOperationController.executeCommand(@removeBatches);

            function removeBatches()

                statuses = batch.getBatchStatus(batchIds);
                terminal = openmebius.domain.batch.BatchConfig ...
                    .isTerminalStatus(statuses);

                if any(terminal) && isempty(resultLocation)
                    error( ...
                        "OpenMebius2:BatchRemoval:" + ...
                        "MissingResultLocation", ...
                        "A result location is required to remove " + ...
                    "completed or failed batches.");
                end

                for terminalId = batchIds(terminal)'
                    obj.ArtifactRepository.deleteBatchArtifacts( ...
                        resultLocation, terminalId);
                end

                for batchId = batchIds'
                    batch.removeBatch(batchId);
                end

            end

        end % remove

        function outcome = applyExperimentSelection( ...
                ~, batch, selection)

            arguments
                ~
                batch
                selection (1, 1) openmebius.domain.batch ...
                    .BatchExperimentSelection
            end

            outcome = openmebius.application.batch ...
                .BatchOperationController.executeCommand(@applySelection);

            function applySelection()

                experiments = selection.Experiments;

                switch selection.Mode
                    case "parallel"

                        if selection.AddAsParallel
                            config = struct( ...
                                numExperiments = numel(experiments), ...
                                isParallel = true);
                            batch.addBatch( ...
                                strjoin(experiments, ", "), ...
                                {experiments'}, ...
                                "Added parallel item", ...
                                config);
                        else

                            for experimentIndex = 1:numel(experiments)
                                experiment = experiments(experimentIndex);
                                batch.addBatch( ...
                                    experiment, ...
                                    {experiment}, ...
                                    "Added item", ...
                                    struct());
                            end

                        end

                    case "inst-mfa"
                        config = struct( ...
                            numExperiments = numel(experiments), ...
                            isParallel = false, ...
                            isINSTMFA = true);
                        batch.editBatch( ...
                            selection.BatchId, ...
                            strjoin(experiments, ", "), ...
                            {experiments'}, ...
                            "Added INST-MFA item", ...
                            config);
                end

            end

        end % applyExperimentSelection

    end % methods

    methods (Static, Access = private)

        function outcome = executeCommand(command)

            try
                command();
                outcome = openmebius.application.batch ...
                    .BatchOperationOutcome(true);
            catch exception
                outcome = openmebius.application.batch ...
                    .BatchOperationOutcome( ...
                    false, ...
                    ErrorMessage = string(exception.message), ...
                    Exception = exception);
            end

        end % executeCommand

    end % methods (Static, Access = private)

end % classdef
