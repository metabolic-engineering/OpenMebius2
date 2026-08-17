classdef AnalysisProvenanceBuilder
    % ANALYSISPROVENANCEBUILDER
    % Resolves and fingerprints the inputs that define one analysis.

    properties (SetAccess = private)
        HashFile
    end

    methods

        function obj = AnalysisProvenanceBuilder(options)

            arguments
                options.HashFile (1, 1) function_handle = ...
                    @(pathFile) openmebius.infrastructure.filesystem ...
                    .FileHasher.hashFile(pathFile)
            end

            obj.HashFile = options.HashFile;

        end % constructor

        function provenance = build( ...
                obj, config, batchId, model, experiments, experimentNames)

            arguments
                obj (1, 1) openmebius.application.analysis ...
                    .AnalysisProvenanceBuilder
                config (1, 1) struct
                batchId (1, 1) string
                model
                experiments
                experimentNames string
            end

            experimentNames = string(experimentNames(:));
            [experimentFiles, experimentHashes] = ...
                obj.resolveExperimentFiles(experiments, experimentNames);
            modelPath = obj.modelPath(model);
            [~, modelName, modelExtension] = fileparts(modelPath);
            modelFileName = string(modelName) + string(modelExtension);
            modelHash = string(obj.HashFile(modelPath));
            semanticConfig = ...
                openmebius.domain.batch.BatchIdentity.semanticConfig(config);
            contentHash = ...
                openmebius.domain.batch.BatchIdentity.contentHash( ...
                config, ...
                modelHash, ...
                experimentNames, ...
                experimentHashes);

            provenance = struct( ...
                'schemaVersion', 1, ...
                'batchId', batchId, ...
                'contentHash', contentHash, ...
                'contentHashVersion', ...
                openmebius.domain.batch.BatchIdentity.ContentHashVersion, ...
                'configJson', ...
                openmebius.domain.batch.BatchIdentity.canonicalJson( ...
                semanticConfig), ...
                'modelFileName', modelFileName, ...
                'modelSha256', modelHash, ...
                'experimentNames', experimentNames, ...
                'experimentFileNames', experimentFiles, ...
                'experimentSha256', experimentHashes);

        end % build

    end % methods

    methods (Access = private)

        function [fileNames, hashes] = resolveExperimentFiles( ...
                obj, experiments, experimentNames)

            availableFiles = string(experiments.fileExpList(:));
            availableNames = strings(size(availableFiles));

            for i = 1:numel(availableFiles)
                [~, name] = fileparts(availableFiles(i));
                availableNames(i) = string(name);
            end

            fileNames = strings(size(experimentNames));
            hashes = strings(size(experimentNames));
            experimentLocation = experiments.getExperimentLocation();

            for i = 1:numel(experimentNames)
                idx = find(availableNames == experimentNames(i), 1);

                if isempty(idx)
                    idx = find(availableFiles == experimentNames(i), 1);
                end

                if isempty(idx)
                    continue
                end

                fileNames(i) = availableFiles(idx);
                pathFile = experimentLocation.workbookFile(fileNames(i));
                hashes(i) = string(obj.HashFile(pathFile));
            end

        end % resolveExperimentFiles

        function path = modelPath(~, model)

            if isstruct(model) && isfield(model, 'pathModel')
                path = string(model.pathModel);
                return
            end

            if isobject(model) && ismethod(model, 'getModelFilePath')
                path = string(model.getModelFilePath());
                return
            end

            error( ...
                "OpenMebius2:AnalysisProvenanceBuilder:MissingModelPath", ...
                "The model does not expose its source-file path.");

        end % modelPath

    end % methods (Access = private)

end % classdef
