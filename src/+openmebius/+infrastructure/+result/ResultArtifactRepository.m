classdef ResultArtifactRepository
    % RESULTARTIFACTREPOSITORY Removes files owned by one analysis result.

    methods

        function deletedFiles = deleteBatchArtifacts( ...
                ~, resultLocation, batchId)

            arguments
                ~
                resultLocation (1, 1) ...
                    openmebius.domain.result.ResultLocation
                batchId (1, 1) string
            end

            artifacts = resultLocation.resultArtifactFiles(batchId);
            deleted = false(size(artifacts));

            for i = 1:numel(artifacts)

                if ~isfile(artifacts(i))
                    continue
                end

                try
                    delete(artifacts(i));
                    deleted(i) = true;
                catch cause
                    exception = MException( ...
                        "OpenMebius2:ResultArtifactRepository:" + ...
                        "DeleteFailed", ...
                        "Unable to delete result artifact: %s", ...
                        artifacts(i));
                    exception = addCause(exception, cause);
                    throwAsCaller(exception);
                end

            end

            deletedFiles = artifacts(deleted);

        end % deleteBatchArtifacts

    end % methods

end % classdef
