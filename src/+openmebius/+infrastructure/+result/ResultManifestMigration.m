classdef ResultManifestMigration
    % RESULTMANIFESTMIGRATION Normalizes persisted manifest documents.

    properties (Constant)
        CurrentSchemaVersion = 1
    end

    methods (Static)

        function document = toCurrentDocument(document)

            if ~isstruct(document) || ~isscalar(document)
                error( ...
                    "OpenMebius2:ResultManifestMigration:InvalidDocument", ...
                    "A result manifest must contain one JSON object.");
            end

            schemaVersion = openmebius.infrastructure.result ...
                .ResultManifestMigration.schemaVersion(document);
            currentVersion = openmebius.infrastructure.result ...
                .ResultManifestMigration.CurrentSchemaVersion;

            if schemaVersion > currentVersion
                error( ...
                    "OpenMebius2:ResultManifestMigration:" + ...
                    "UnsupportedSchemaVersion", ...
                    "Unsupported result manifest schemaVersion: %d.", ...
                    schemaVersion);
            end

            if schemaVersion == 0
                document.schemaVersion = currentVersion;
            end

        end

    end

    methods (Static, Access = private)

        function version = schemaVersion(document)

            if ~isfield(document, "schemaVersion")
                version = 0;
                return
            end

            value = document.schemaVersion;

            if isnumeric(value) || islogical(value)
                version = double(value);
            else
                version = str2double(string(value));
            end

            if ~isscalar(version) || ~isfinite(version) || ...
                    version < 0 || fix(version) ~= version
                error( ...
                    "OpenMebius2:ResultManifestMigration:" + ...
                    "InvalidSchemaVersion", ...
                    "Result manifest schemaVersion must be a " + ...
                    "nonnegative integer.");
            end

        end

    end

end
