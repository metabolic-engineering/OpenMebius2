classdef BatchConfigurationLaunchRequest
    % BATCHCONFIGURATIONLAUNCHREQUEST Selected batches for RunConfig.

    properties (SetAccess = private)
        BatchIds (:, 1) string
        TableData table
    end

    methods

        function obj = BatchConfigurationLaunchRequest(batchIds, options)

            arguments
                batchIds (:, 1) string
                options.TableData table = table()
            end

            batchIds = strip(batchIds(:));

            if isempty(batchIds) || ...
                    any(ismissing(batchIds) | batchIds == "")
                error( ...
                    "OpenMebius2:BatchConfigurationLaunchRequest:" + ...
                    "InvalidBatchIds", ...
                    "Select at least one batch to configure.");
            end

            if numel(unique(batchIds, "stable")) ~= numel(batchIds)
                error( ...
                    "OpenMebius2:BatchConfigurationLaunchRequest:" + ...
                    "DuplicateBatchIds", ...
                    "Batch configuration selection contains " + ...
                    "duplicate IDs.");
            end

            obj.BatchIds = batchIds;
            obj.TableData = options.TableData;

        end % constructor

    end % methods

end % classdef
