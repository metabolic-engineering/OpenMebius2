classdef BatchIdentity
    % BATCHIDENTITY
    % Creates stable batch IDs and hashes reproducible analysis inputs.

    properties (Constant)
        ContentHashVersion = 1
    end

    methods (Static)

        function id = newId(existingIds)

            if nargin < 1
                existingIds = strings(0, 1);
            end

            existingIds = string(existingIds(:));

            while true
                uuid = lower(erase(string(java.util.UUID.randomUUID()), "-"));
                id = "bat_" + uuid;

                if ~any(existingIds == id)
                    return
                end
            end

        end % newId

        function hash = contentHash(config, modelHash, experimentNames, experimentHashes)

            arguments
                config struct
                modelHash (1, 1) string = ""
                experimentNames string = strings(0, 1)
                experimentHashes string = strings(0, 1)
            end

            experimentNames = string(experimentNames(:));
            experimentHashes = string(experimentHashes(:));

            if numel(experimentNames) ~= numel(experimentHashes)
                error( ...
                    "OpenMebius2:BatchIdentity:ExperimentHashMismatch", ...
                    "Each experiment must have one corresponding SHA-256 hash.");
            end

            payload = struct( ...
                'contentHashVersion', ...
                openmebius.domain.batch.BatchIdentity.ContentHashVersion, ...
                'modelSha256', ...
                string(modelHash), ...
                'experiments', ...
                struct( ...
                    'name', cellstr(experimentNames), ...
                    'sha256', cellstr(experimentHashes)), ...
                'config', ...
                openmebius.domain.batch.BatchIdentity.semanticConfig(config));

            json = openmebius.domain.batch.BatchIdentity.canonicalJson(payload);
            bytes = unicode2native(char(json), 'UTF-8');
            hash = "sha256:" + string(utils.sha256_uint8(uint8(bytes)));

        end % contentHash

        function config = semanticConfig(config)

            config = openmebius.domain.batch.BatchConfig.normalize(config);
            volatileFields = {'status', 'deleteResultFile', 'random'};
            presentFields = volatileFields(isfield(config, volatileFields));

            if ~isempty(presentFields)
                config = rmfield(config, presentFields);
            end

            config = openmebius.domain.batch.BatchIdentity.canonicalize(config);

        end % semanticConfig

        function json = canonicalJson(value)

            value = openmebius.domain.batch.BatchIdentity.canonicalize(value);
            json = string(jsonencode(value));

        end % canonicalJson

    end % methods (Static)

    methods (Static, Access = private)

        function value = canonicalize(value)

            if isstruct(value)
                value = orderfields(value);
                fields = fieldnames(value);

                for iValue = 1:numel(value)
                    for iField = 1:numel(fields)
                        field = fields{iField};
                        value(iValue).(field) = ...
                            openmebius.domain.batch.BatchIdentity.canonicalize( ...
                            value(iValue).(field));
                    end
                end

                return
            end

            if iscell(value)
                for i = 1:numel(value)
                    value{i} = ...
                        openmebius.domain.batch.BatchIdentity.canonicalize(value{i});
                end
            end

        end % canonicalize

    end % methods (Static, Access = private)

end % classdef
