classdef BatchExecutionCoordinator
    % BATCHEXECUTIONCOORDINATOR Coordinates all runnable batch entries.

    properties (SetAccess = private)
        RunService
        ProvenanceBuilder
    end

    methods

        function obj = BatchExecutionCoordinator(options)

            arguments
                options.RunService = ...
                    openmebius.application.batch.BatchRunService()
                options.ProvenanceBuilder = ...
                    openmebius.application.analysis ...
                    .AnalysisProvenanceBuilder()
            end

            obj.RunService = options.RunService;
            obj.ProvenanceBuilder = options.ProvenanceBuilder;

        end % constructor

        function [batchTable, status] = run( ...
                obj, batchTable, model, experiments, resultLocation, options)

            arguments
                obj (1, 1) openmebius.application.batch ...
                    .BatchExecutionCoordinator
                batchTable table
                model
                experiments
                resultLocation (1, 1) ...
                    openmebius.domain.result.ResultLocation
                options.Controller = []
                options.ProgressReporter (1, 1) function_handle = @(~) []
                options.CheckpointWriter (1, 1) function_handle = @(~) []
                options.MessageReporter (1, 1) function_handle = @(~) []
                options.ResultReporter (1, 1) function_handle = @(~) []
            end

            status = "finished";
            numberOfBatches = height(batchTable);

            for i = 1:numberOfBatches
                progress = struct( ...
                    'id', batchTable.id(i), ...
                    'status', "finished", ...
                    'rate', i / numberOfBatches);
                entryStatus = string(batchTable.config(i).status);

                if entryStatus == "finished"
                    options.ProgressReporter(progress);
                    continue
                end

                if entryStatus ~= "ready"
                    progress.status = "question";
                    options.ProgressReporter(progress);
                    continue
                end

                if batchTable.config(i).deleteResultFile
                    obj.deleteResultArtifacts( ...
                        resultLocation, batchTable.id(i));
                end

                provenance = obj.ProvenanceBuilder.build( ...
                    batchTable.config(i), ...
                    batchTable.id(i), ...
                    model, ...
                    experiments, ...
                    batchTable.exp{i});
                analysisStatus = obj.RunService.run( ...
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

                if analysisStatus == "canceled"
                    status = "canceled";
                    break
                end

                if analysisStatus == "error"
                    progress.status = "error";
                    status = "error";
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

    methods (Static, Access = private)

        function deleteResultArtifacts(resultLocation, batchId)

            artifacts = resultLocation.resultArtifactFiles(batchId);

            for i = 1:numel(artifacts)
                if isfile(artifacts(i))
                    delete(artifacts(i));
                end
            end

        end % deleteResultArtifacts

    end % methods (Static, Access = private)

end % classdef
