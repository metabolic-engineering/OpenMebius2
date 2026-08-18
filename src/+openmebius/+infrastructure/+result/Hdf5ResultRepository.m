classdef Hdf5ResultRepository < handle
    % HDF5RESULTREPOSITORY
    % Writes flux analysis result datasets to HDF5.

    methods

        function data = readResultData(obj, resultLocation, id, options)

            arguments
                obj
                resultLocation openmebius.domain.result.ResultLocation
                id (1, 1) string
                options.ReadStatus (1, 4) logical = ...
                    [true, true, true, true]
            end

            filePath = obj.requireResultFile(resultLocation, id);
            data = struct;
            data.ID = h5read(filePath, "/ID");
            data.status = h5read(filePath, "/status");

            enabledStatus = logical(data.status(:).') & ...
                options.ReadStatus;

            if enabledStatus(1)
                data.model.modelID = ...
                    h5read(filePath, "/model/modelID");
                data.model.modelReaction = ...
                    h5read(filePath, "/model/modelReaction");
                data.MDVExp = h5read(filePath, "/MDVExp");
                data.MDVExpName = h5read(filePath, "/MDVFragList");
                data.MDVFragMask = h5read(filePath, "/MDVFragMask");
                data.fluxVariability.fluxUBFwd = h5read( ...
                    filePath, "/fluxVariability/fluxUBFwd");
                data.fluxVariability.fluxLBFwd = h5read( ...
                    filePath, "/fluxVariability/fluxLBFwd");
                data.fluxVariability.time = h5read( ...
                    filePath, "/fluxVariability/time");

                data.initialFlux.fluxFwd = h5read( ...
                    filePath, "/initialFlux/fluxFwd");
                data.initialFlux.RSS = h5read( ...
                    filePath, "/initialFlux/RSS");
                data.initialFlux.time = h5read( ...
                    filePath, "/initialFlux/time");
            end

            if enabledStatus(2)
                data.RSS = h5read(filePath, "/RSS");
                data.RSSIdx = h5read(filePath, "/RSSIndex");
                data.threshold = h5read(filePath, "/threshold");

                for i = 1:length(data.RSSIdx)
                    iterationName = string(sprintf( ...
                        "%04d", data.RSSIdx(i)));
                    fieldName = "fluxResult" + iterationName;
                    address = "/fluxResult/" + iterationName;
                    data.(fieldName).fluxFwd = h5read( ...
                        filePath, address + "/fluxFwd");
                    data.(fieldName).RSS = h5read( ...
                        filePath, address + "/RSS");
                    data.(fieldName).MDV = h5read( ...
                        filePath, address + "/MDV");
                    data.(fieldName).exitflag = h5read( ...
                        filePath, address + "/exitflag");
                    data.(fieldName).time = h5read( ...
                        filePath, address + "/time");
                end

            end

            if enabledStatus(3)
                data.fluxLB = h5read(filePath, "/fluxLB");
                data.fluxUB = h5read(filePath, "/fluxUB");

                try
                    data.CI.algorithm = string( ...
                        h5read(filePath, "/CI/algorithm"));

                    if data.CI.algorithm == "Grid search"
                        data.CI.fluxLB = h5read( ...
                            filePath, "/CI/fluxLB");
                        data.CI.fluxUB = h5read( ...
                            filePath, "/CI/fluxUB");
                        data.CI.gridSearch = ...
                            obj.readGridSearchData(filePath);
                    end

                catch
                    % CI metadata is optional for legacy result files.
                end

            end

        end % readResultData

        function snapshot = readBatchSnapshot(obj, resultLocation, id)

            arguments
                obj
                resultLocation openmebius.domain.result.ResultLocation
                id (1, 1) string
            end

            filePath = obj.requireResultFile(resultLocation, id);
            storedId = obj.readOptionalDataset(filePath, "/metadata/batch/id", []);

            if isempty(storedId)
                storedId = obj.readOptionalDataset(filePath, "/ID", id);
            end

            snapshot = struct;
            snapshot.ID = obj.scalarString(storedId, id);
            snapshot.Name = obj.scalarString( ...
                obj.readOptionalDataset( ...
                filePath, "/metadata/batch/name", ""), "");
            snapshot.Experiments = string(obj.readOptionalDataset( ...
                filePath, "/metadata/experiments/names", strings(0, 1)));
            snapshot.Experiments = snapshot.Experiments(:);
            snapshot.Description = obj.scalarString( ...
                obj.readOptionalDataset( ...
                filePath, "/metadata/batch/description", ""), "");
            snapshot.ConfigJson = obj.scalarString( ...
                obj.readOptionalDataset( ...
                filePath, "/metadata/batch/configJson", ""), "");
            snapshot.ContentHash = obj.scalarString( ...
                obj.readOptionalDataset( ...
                filePath, "/metadata/batch/contentHash", ""), "");
            snapshot.StartedAtUtc = obj.scalarString( ...
                obj.readOptionalDataset( ...
                filePath, "/metadata/run/startedAtUtc", ""), "");
            snapshot.FinishedAtUtc = obj.scalarString( ...
                obj.readOptionalDataset( ...
                filePath, "/metadata/run/finishedAtUtc", ""), "");

            isError = logical(obj.readOptionalDataset( ...
                filePath, "/metadata/run/isError", int8(0)));
            isCanceled = logical(obj.readOptionalDataset( ...
                filePath, "/metadata/run/isCanceled", int8(0)));
            snapshot.Status = "finished";

            if any(isCanceled(:))
                snapshot.Status = "canceled";
            elseif any(isError(:))
                snapshot.Status = "error";
            end

        end % readBatchSnapshot

        function data = readConfidenceInterval( ...
                obj, resultLocation, id, reactionId)

            arguments
                obj
                resultLocation openmebius.domain.result.ResultLocation
                id (1, 1) string
                reactionId (1, 1) string
            end

            filePath = obj.requireResultFile(resultLocation, id);
            status = h5read(filePath, "/status");
            data = [];

            if numel(status) < 3 || ...
                    ~(status(1) && status(2) && status(3))
                return
            end

            data = struct;
            data.status = status;
            data.RxnID = reactionId;
            data.model.modelID = h5read(filePath, "/model/modelID");
            data.model.modelReaction = h5read( ...
                filePath, "/model/modelReaction");
            data.fluxVariability.fluxUBFwd = h5read( ...
                filePath, "/fluxVariability/fluxUBFwd");
            data.fluxVariability.fluxLBFwd = h5read( ...
                filePath, "/fluxVariability/fluxLBFwd");
            data.RSSIdx = h5read(filePath, "/RSSIndex");
            iterationName = string(sprintf("%04d", data.RSSIdx(1)));
            data.fluxFwd = h5read( ...
                filePath, "/fluxResult/" + iterationName + "/fluxFwd");
            data.fluxLB = h5read(filePath, "/fluxLB");
            data.fluxUB = h5read(filePath, "/fluxUB");
            data.CI.algorithm = string(h5read(filePath, "/CI/algorithm"));

            if data.CI.algorithm == "Monte Carlo"
                data.CI.flux = h5read(filePath, "/CI/fluxes");
                data.CI.fluxLB = h5read(filePath, "/CI/fluxLB");
                data.CI.fluxUB = h5read(filePath, "/CI/fluxUB");
            elseif data.CI.algorithm == "Grid search"
                data.CI.fluxLB = h5read(filePath, "/CI/fluxLB");
                data.CI.fluxUB = h5read(filePath, "/CI/fluxUB");
                data.CI.gridSearch = obj.readGridSearchData(filePath);
            end

        end % readConfidenceInterval

        function data = readOptimizationState(obj, resultLocation, id)

            arguments
                obj
                resultLocation openmebius.domain.result.ResultLocation
                id (1, 1) string
            end

            filePath = obj.requireResultFile(resultLocation, id);
            status = h5read(filePath, "/status");
            data = [];

            if numel(status) < 2 || ~status(2)
                return
            end

            data = struct;
            data.RSS = h5read(filePath, "/RSS");
            data.threshold = h5read(filePath, "/threshold");

        end % readOptimizationState

        function [isAvailable, data] = readNextLabelSuggestion( ...
                ~, resultLocation, id)

            arguments
                ~
                resultLocation openmebius.domain.result.ResultLocation
                id (1, 1) string
            end

            isAvailable = resultLocation.hasResultFile(id);
            data = struct;

            if ~isAvailable
                return
            end

            filePath = resultLocation.resultFile(id);

            try
                data.ID = h5read(filePath, "/model/modelID");
                data.ID = [data.ID; "biomass"];
                data.rxn = h5read(filePath, "/model/modelReaction");
                data.rxn = [data.rxn; "biomass"];
                data.colName = h5read( ...
                    filePath, "/nextLabelPattern/suggestionTable/colName");
                data.data = h5read( ...
                    filePath, "/nextLabelPattern/suggestionTable/data");
                data.fluxLB = h5read(filePath, "/fluxLB");
                data.fluxUB = h5read(filePath, "/fluxUB");
                rssIndex = h5read(filePath, "/RSSIndex");
                iterationName = string(sprintf("%04d", rssIndex(1)));
                data.bestfit = h5read( ...
                    filePath, ...
                    "/fluxResult/" + iterationName + "/fluxFwd");
                data.FVALB = h5read( ...
                    filePath, "/fluxVariability/fluxLBFwd");
                data.FVAUB = h5read( ...
                    filePath, "/fluxVariability/fluxUBFwd");
            catch
                isAvailable = false;
                data = struct;
                return
            end

            try
                numPatterns = size(data.data, 1);
                data.patternLabel = strings(numPatterns, 1);

                for i = 1:numPatterns
                    pattern = data.data(i, :);
                    patternName = matlab.lang.makeValidName( ...
                        strjoin(pattern, '_'));
                    data.patternLabel(i) = patternName;
                    data.(patternName).fluxLB = h5read( ...
                        filePath, ...
                        "/nextLabelPattern/" + patternName + "/fluxLB");
                    data.(patternName).fluxUB = h5read( ...
                        filePath, ...
                        "/nextLabelPattern/" + patternName + "/fluxUB");
                end

            catch
                % Per-pattern bounds are optional for legacy result files.
            end

        end % readNextLabelSuggestion

        function assertResultDirectory(~, resultLocation)

            arguments
                ~
                resultLocation openmebius.domain.result.ResultLocation
            end

            if ~resultLocation.directoryExists()
                error( ...
                    "OpenMebius2:Hdf5ResultRepository:DirectoryNotFound", ...
                    "Result directory does not exist: %s", ...
                    resultLocation.Directory);
            end

        end % assertResultDirectory

        function [isSuccess, msg] = writeDataset(~, pathFile, pathData, data, options)

            arguments
                ~
                pathFile (1, 1) string
                pathData (1, 1) string
                data
                options.DataType (1, 1) string = "double"
            end

            [isSuccess, msg] = openmebius.infrastructure.filesystem.Hdf5FileStore ...
                .writeDataset( ...
                pathFile, ...
                pathData, ...
                data, ...
                DataType = options.DataType);

        end % writeDataset

        function [isSuccess, msg] = writeAnalysisMetadata(obj, pathFile, metadata)

            arguments
                obj
                pathFile (1, 1) string
                metadata (1, 1) struct
            end

            paths = { ...
                "/metadata/schemaVersion"; ...
                "/metadata/batch/id"; ...
                "/metadata/batch/name"; ...
                "/metadata/batch/description"; ...
                "/metadata/batch/contentHash"; ...
                "/metadata/batch/contentHashVersion"; ...
                "/metadata/batch/configJson"; ...
                "/metadata/software/openMebius2Version"; ...
                "/metadata/software/matlabRelease"; ...
                "/metadata/software/matlabVersion"; ...
                "/metadata/software/toolboxesJson"; ...
                "/metadata/model/fileName"; ...
                "/metadata/model/sha256"; ...
                "/metadata/experiments/names"; ...
                "/metadata/experiments/fileNames"; ...
                "/metadata/experiments/sha256"; ...
                "/metadata/random/type"; ...
                "/metadata/random/seed"; ...
                "/metadata/random/state"; ...
                "/metadata/run/startedAtUtc"};
            values = { ...
                int32(metadata.schemaVersion); ...
                string(metadata.batchId); ...
                string(obj.metadataValue( ...
                metadata, 'batchName', "")); ...
                string(obj.metadataValue( ...
                metadata, 'batchDescription', "")); ...
                string(metadata.contentHash); ...
                int32(metadata.contentHashVersion); ...
                string(metadata.configJson); ...
                string(metadata.openMebius2Version); ...
                string(metadata.matlabRelease); ...
                string(metadata.matlabVersion); ...
                string(metadata.toolboxesJson); ...
                string(metadata.modelFileName); ...
                string(metadata.modelSha256); ...
                string(metadata.experimentNames(:)); ...
                string(metadata.experimentFileNames(:)); ...
                string(metadata.experimentSha256(:)); ...
                string(metadata.randomType); ...
                uint32(metadata.randomSeed); ...
                uint32(metadata.randomState(:)); ...
                string(metadata.startedAtUtc)};
            dataTypes = { ...
                "int32"; "string"; "string"; "string"; ...
                "string"; "int32"; "string"; ...
                "string"; "string"; "string"; "string"; ...
                "string"; "string"; "string"; "string"; "string"; ...
                "string"; "uint32"; "uint32"; "string"};

            isSuccess = true;
            msg = "";

            for i = 1:numel(paths)

                if isempty(values{i})
                    continue
                end

                [isSuccess, msg] = obj.writeDataset( ...
                    pathFile, ...
                    paths{i}, ...
                    values{i}, ...
                    DataType = dataTypes{i});

                if ~isSuccess
                    return
                end

            end

        end % writeAnalysisMetadata

        function [isSuccess, msg] = writeRunCompletion( ...
                obj, pathFile, finishedAtUtc, isError, isCanceled)

            [isSuccess, msg] = obj.writeDataset( ...
                pathFile, ...
                "/metadata/run/finishedAtUtc", ...
                string(finishedAtUtc), ...
                DataType = "string");

            if ~isSuccess
                return
            end

            [isSuccess, msg] = obj.writeDataset( ...
                pathFile, ...
                "/metadata/run/isError", ...
                int8(isError), ...
                DataType = "int8");

            if ~isSuccess
                return
            end

            [isSuccess, msg] = obj.writeDataset( ...
                pathFile, ...
                "/metadata/run/isCanceled", ...
                int8(isCanceled), ...
                DataType = "int8");

        end % writeRunCompletion

    end % methods

    methods (Access = private)

        function data = readGridSearchData(obj, filePath)

            basePath = "/CI/gridSearch";
            data = struct;
            data.fluxIndices = double(h5read( ...
                filePath, basePath + "/fluxIndices"));
            data.reactionIDs = string(h5read( ...
                filePath, basePath + "/reactionIDs"));
            data.fixedFlux = h5read( ...
                filePath, basePath + "/fixedFlux");
            data.RSS = h5read(filePath, basePath + "/RSS");
            data.minimumRSS = h5read( ...
                filePath, basePath + "/minimumRSS");
            data.bestObjective = h5read( ...
                filePath, basePath + "/bestObjective");
            data.objectiveThreshold = h5read( ...
                filePath, basePath + "/objectiveThreshold");
            data.pointCount = double(h5read( ...
                filePath, basePath + "/pointCount"));
            data.trialCount = double(h5read( ...
                filePath, basePath + "/trialCount"));
            data.workerCount = double(obj.readOptionalDataset( ...
                filePath, basePath + "/workerCount", NaN));
            data.maximumTrial = double(h5read( ...
                filePath, basePath + "/maximumTrial"));
            data.minimumFluxRange = double( ...
                obj.readOptionalDataset( ...
                filePath, basePath + "/minimumFluxRange", NaN));
            data.alpha = h5read(filePath, basePath + "/alpha");
            data.thresholdType = string(h5read( ...
                filePath, basePath + "/thresholdType"));
            data.intervalMode = string(h5read( ...
                filePath, basePath + "/intervalMode"));
            data.executionMode = string(h5read( ...
                filePath, basePath + "/executionMode"));
            data.delta = h5read(filePath, basePath + "/delta");
            data.elapsedTime = h5read( ...
                filePath, basePath + "/elapsedTime");

        end % readGridSearchData

        function value = metadataValue(~, metadata, fieldName, defaultValue)

            value = defaultValue;

            if isfield(metadata, fieldName) && ...
                    ~isempty(metadata.(fieldName))
                value = metadata.(fieldName);
            end

        end % metadataValue

        function value = readOptionalDataset(~, filePath, pathData, defaultValue)

            value = defaultValue;

            try
                value = h5read(filePath, pathData);
            catch
                % Result metadata is optional for legacy result files.
            end

        end % readOptionalDataset

        function value = scalarString(~, rawValue, defaultValue)

            value = string(rawValue);

            if isempty(value)
                value = string(defaultValue);
            else
                value = value(1);
            end

        end % scalarString

        function pathFile = requireResultFile(~, resultLocation, id)

            if ~resultLocation.hasResultFile(id)
                error( ...
                    "OpenMebius2:Hdf5ResultRepository:ResultFileNotFound", ...
                    "Result file does not exist: %s", ...
                    resultLocation.resultFile(id));
            end

            pathFile = resultLocation.resultFile(id);

        end % requireResultFile

    end % methods (Access = private)

end % classdef
