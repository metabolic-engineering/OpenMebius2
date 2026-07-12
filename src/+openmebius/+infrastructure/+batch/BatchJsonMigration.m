classdef BatchJsonMigration
    % BATCHJSONMIGRATION
    % Migrates batch JSON documents to the current schema.

    methods (Static)

        function schemaVersion = currentSchemaVersion()

            schemaVersion = 1;

        end % currentSchemaVersion

        function document = createCurrentDocument(batchData)

            document = struct( ...
                'schemaVersion', ...
                openmebius.infrastructure.batch.BatchJsonMigration.currentSchemaVersion(), ...
                'batches', ...
                {batchData});

        end % createCurrentDocument

        function document = toCurrentDocument(jsonData)

            document = openmebius.infrastructure.batch.BatchJsonMigration.unpack( ...
                jsonData);

            schemaVersion = document.schemaVersion;
            currentSchemaVersion = ...
                openmebius.infrastructure.batch.BatchJsonMigration.currentSchemaVersion();

            if schemaVersion > currentSchemaVersion
                error( ...
                    "OpenMebius2:BatchJsonMigration:UnsupportedSchemaVersion", ...
                    "Unsupported batch JSON schemaVersion: %d.", ...
                    schemaVersion);
            end

            while schemaVersion < currentSchemaVersion

                switch schemaVersion

                    case 0
                        document = ...
                            openmebius.infrastructure.batch.BatchJsonMigration.v0ToV1( ...
                            document);

                    otherwise
                        error( ...
                            "OpenMebius2:BatchJsonMigration:UnsupportedSchemaVersion", ...
                            "Unsupported batch JSON schemaVersion: %d.", ...
                            schemaVersion);
                end

                schemaVersion = document.schemaVersion;

            end

        end % toCurrentDocument

    end % methods

    methods (Static, Access = private)

        function document = unpack(jsonData)

            if openmebius.infrastructure.batch.BatchJsonMigration.isVersionedDocument( ...
                    jsonData)
                schemaVersion = ...
                    openmebius.infrastructure.batch.BatchJsonMigration.parseSchemaVersion( ...
                    jsonData.schemaVersion);
                batchData = jsonData.batches;
            else
                schemaVersion = 0;
                batchData = jsonData;
            end

            document = struct( ...
                'schemaVersion', ...
                schemaVersion, ...
                'batches', ...
                {batchData});

        end % unpack

        function tf = isVersionedDocument(jsonData)

            tf = isstruct(jsonData) && ...
                isscalar(jsonData) && ...
                isfield(jsonData, 'schemaVersion') && ...
                isfield(jsonData, 'batches');

        end % isVersionedDocument

        function schemaVersion = parseSchemaVersion(value)

            if isnumeric(value) || islogical(value)
                schemaVersion = double(value);
            elseif ischar(value) || isstring(value)
                schemaVersion = str2double(string(value));
            else
                schemaVersion = NaN;
            end

            if ~isscalar(schemaVersion) || ...
                    isnan(schemaVersion) || ...
                    schemaVersion < 0 || ...
                    fix(schemaVersion) ~= schemaVersion
                error( ...
                    "OpenMebius2:BatchJsonMigration:InvalidSchemaVersion", ...
                    "Batch JSON schemaVersion must be a nonnegative integer.");
            end

        end % parseSchemaVersion

        function document = v0ToV1(document)

            document = ...
                openmebius.infrastructure.batch.BatchJsonMigration.createCurrentDocument( ...
                document.batches);

        end % v0ToV1

    end % methods

end % classdef
