classdef BatchExecutionCoordinator
    % BATCHEXECUTIONCOORDINATOR Coordinates all runnable batch entries.

    properties (SetAccess = private)
        RunService
        ArtifactRepository
    end

    methods

        function obj = BatchExecutionCoordinator(options)

            arguments
                options.RunService = ...
                    openmebius.application.batch.BatchRunService()
                options.ArtifactRepository = ...
                    openmebius.infrastructure.result ...
                    .ResultArtifactRepository()
            end

            obj.RunService = options.RunService;
            obj.ArtifactRepository = options.ArtifactRepository;

        end % constructor

        function [batchTable, result] = run( ...
                obj, batchTable, model, experiments, resultLocation, ...
                provenances, options)

            arguments
                obj (1, 1) openmebius.application.batch ...
                    .BatchExecutionCoordinator
                batchTable table
                model
                experiments
                resultLocation (1, 1) ...
                    openmebius.domain.result.ResultLocation
                provenances cell
                options.Controller = []
                options.ProgressReporter (1, 1) function_handle = @(~) []
                options.CheckpointWriter (1, 1) function_handle = @(~) []
                options.MessageReporter (1, 1) function_handle = @(~) []
                options.ResultReporter (1, 1) function_handle = @(~) []
            end

            result = openmebius.application.batch.BatchExecutionResult(true);
            numberOfBatches = height(batchTable);

            if numel(provenances) ~= numberOfBatches
                error( ...
                    "OpenMebius2:BatchExecutionCoordinator:" + ...
                    "ProvenanceCountMismatch", ...
                "Each batch entry must have one prepared provenance value.");
            end

            for i = 1:numberOfBatches
                progress = struct( ...
                    'id', batchTable.id(i), ...
                    'status', "finished", ...
                    'rate', i / numberOfBatches);
                entryStatus = string(batchTable.config(i).status);

                if openmebius.domain.batch.BatchConfig ...
                        .isTerminalStatus(entryStatus)
                    continue
                end

                if entryStatus ~= "ready"
                    progress.status = "question";
                    options.ProgressReporter(progress);
                    continue
                end

                if batchTable.config(i).deleteResultFile
                    obj.ArtifactRepository.deleteBatchArtifacts( ...
                        resultLocation, batchTable.id(i));
                end

                provenance = provenances{i};

                if ~isstruct(provenance) || ~isscalar(provenance)
                    error( ...
                        "OpenMebius2:BatchExecutionCoordinator:" + ...
                        "MissingProvenance", ...
                        "Runnable batch %s has no prepared provenance.", ...
                        batchTable.id(i));
                end

                analysisResult = obj.RunService.run( ...
                    model, ...
                    experiments, ...
                    batchTable.exp(i), ...
                    batchTable.config(i), ...
                    resultLocation, ...
                    batchTable.id(i), ...
                    Controller = options.Controller, ...
                    Provenance = provenance, ...
                    MessageReporter = options.MessageReporter, ...
                    ResultReporter = options.ResultReporter);

                if analysisResult.isCanceled()
                    result = analysisResult;
                    break
                end

                if analysisResult.isFailure()
                    progress.status = "error";
                    result = analysisResult;
                    batchTable.config(i).status = "error";
                    options.ProgressReporter(progress);
                    options.CheckpointWriter(batchTable);
                    continue
                end

                batchTable.config(i).status = "finished";
                options.ProgressReporter(progress);
                options.CheckpointWriter(batchTable);
            end

        end % run

    end % methods

end % classdef
