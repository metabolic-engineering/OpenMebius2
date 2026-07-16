classdef EMUNetworkCacheRepository < handle
    % EMUNETWORKCACHEREPOSITORY
    % Persists EMU network snapshots and validates them against the model.

    methods

        function [snapshot, isLoaded] = load(~, modelLocation, fileName, fileType)

            arguments
                ~
                modelLocation openmebius.domain.model.ModelLocation
                fileName (1, 1) string
                fileType (1, 1) string
            end

            snapshot = [];
            isLoaded = false;

            cacheFile = modelLocation.cacheFile(fileName);
            modelFile = modelLocation.modelFile(fileName, fileType);
            hashFile = modelLocation.hashFile(fileName);

            if ~isfile(cacheFile) || ...
                    ~openmebius.infrastructure.model ...
                        .EMUNetworkCacheRepository.isCurrent( ...
                            modelFile, hashFile)
                return
            end

            try
                payload = load(cacheFile);
                snapshot = openmebius.domain.model.EMUNetworkSnapshot( ...
                    payload);
                isLoaded = true;
            catch ME
                exception = MException( ...
                    "OpenMebius2:EMUNetworkCacheRepository:LoadFailed", ...
                    "Failed to load the EMU cache: %s", ...
                    cacheFile);
                exception = addCause(exception, ME);
                throw(exception);
            end

        end % load

        function save(~, modelLocation, fileName, fileType, snapshot)

            arguments
                ~
                modelLocation openmebius.domain.model.ModelLocation
                fileName (1, 1) string
                fileType (1, 1) string
                snapshot openmebius.domain.model.EMUNetworkSnapshot
            end

            cacheFile = modelLocation.cacheFile(fileName);
            modelFile = modelLocation.modelFile(fileName, fileType);
            hashFile = modelLocation.hashFile(fileName);
            cacheDirectory = string(fileparts(cacheFile));
            temporaryFile = string(tempname(cacheDirectory)) + ".mat";
            cleanup = onCleanup(@() ...
                openmebius.infrastructure.model ...
                    .EMUNetworkCacheRepository.deleteIfExists(temporaryFile));
            payload = snapshot.toStruct();

            try
                save(temporaryFile, "-struct", "payload");
                movefile(temporaryFile, cacheFile, "f");
                openmebius.infrastructure.filesystem.FileHasher ...
                    .saveHashFile(modelFile);

                if ~isfile(hashFile)
                    error( ...
                        "OpenMebius2:EMUNetworkCacheRepository:HashWriteFailed", ...
                        "Failed to save the model hash: %s", ...
                        hashFile);
                end
            catch ME
                exception = MException( ...
                    "OpenMebius2:EMUNetworkCacheRepository:SaveFailed", ...
                    "Failed to save the EMU cache: %s", ...
                    cacheFile);
                exception = addCause(exception, ME);
                throw(exception);
            end

            clear cleanup

        end % save

    end % methods

    methods (Static, Access = private)

        function tf = isCurrent(modelFile, hashFile)

            tf = false;

            if ~isfile(modelFile) || ~isfile(hashFile)
                return
            end

            try
                cachedHash = strtrim(string(fileread(hashFile)));
                currentHash = ...
                    openmebius.infrastructure.filesystem.FileHasher ...
                        .hashFile(modelFile);
                tf = strlength(cachedHash) > 0 && cachedHash == currentHash;
            catch
                tf = false;
            end

        end % isCurrent

        function deleteIfExists(pathFile)

            if isfile(pathFile)
                delete(pathFile);
            end

        end % deleteIfExists

    end % methods (Static, Access = private)

end % classdef
