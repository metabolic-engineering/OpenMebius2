classdef GridSearchParallelPoolManager
    % GRIDSEARCHPARALLELPOOLMANAGER Configures local process pools.

    methods

        function [workerCount, pool] = ensureProcessPool( ...
                ~, requestedWorkerCount)

            arguments
                ~
                requestedWorkerCount (1, 1) double ...
                    {mustBeInteger, mustBePositive}
            end

            pool = gcp("nocreate");
            isRequestedPool = ...
                ~isempty(pool) && ...
                isa(pool, "parallel.ProcessPool") && ...
                pool.NumWorkers == requestedWorkerCount;

            if ~isRequestedPool

                if ~isempty(pool)
                    delete(pool);
                end

                cluster = parcluster("Processes");

                if cluster.NumWorkers < requestedWorkerCount
                    cluster.NumWorkers = requestedWorkerCount;
                end

                pool = parpool(cluster, requestedWorkerCount);
            end

            workerCount = double(pool.NumWorkers);

        end % ensureProcessPool

    end % methods

    methods (Static)

        function count = requestedWorkerCount( ...
                logicalProcessorCount, configuredCount, targetCount)

            arguments
                logicalProcessorCount (1, 1) double ...
                    {mustBeInteger, mustBePositive}
                configuredCount (1, 1) double ...
                    {mustBeInteger, mustBePositive}
                targetCount (1, 1) double ...
                    {mustBeInteger, mustBePositive}
            end

            count = min([ ...
                logicalProcessorCount, configuredCount, targetCount]);

        end % requestedWorkerCount

        function [physicalCoreCount, logicalProcessorCount] = ...
                processorCounts()

            physicalCoreCount = 1;

            try
                physicalCoreCount = double(feature("numcores"));
            catch
                % Retain the conservative fallback when core detection is
                % unavailable on the current MATLAB platform.
            end

            physicalCoreCount = openmebius.mfa ...
                .GridSearchParallelPoolManager.validCount( ...
                physicalCoreCount, 1);
            logicalProcessorCount = physicalCoreCount;

            try
                logicalProcessorCount = double( ...
                    java.lang.Runtime.getRuntime().availableProcessors());
            catch
                environmentCount = str2double( ...
                    getenv("NUMBER_OF_PROCESSORS"));
                logicalProcessorCount = openmebius.mfa ...
                    .GridSearchParallelPoolManager.validCount( ...
                    environmentCount, physicalCoreCount);
            end

            logicalProcessorCount = max( ...
                physicalCoreCount, ...
                openmebius.mfa.GridSearchParallelPoolManager ...
                .validCount(logicalProcessorCount, physicalCoreCount));

        end % processorCounts

    end % methods (Static)

    methods (Static, Access = private)

        function value = validCount(candidate, fallback)

            value = double(candidate);

            if ~isscalar(value) || ~isfinite(value) || value < 1
                value = fallback;
            end

            value = max(1, floor(value));

        end % validCount

    end % methods (Static, Access = private)

end % classdef
