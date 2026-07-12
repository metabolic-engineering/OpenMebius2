classdef FileHasher
    % FILEHASHER
    % Hashes files for cache invalidation and reproducibility checks.

    methods (Static)

        function hash = hashFile(pathFile, options)

            arguments
                pathFile (1, 1) string
                options.Algorithm (1, 1) string ...
                    {mustBeMember(options.Algorithm, "SHA256")} = "SHA256"
            end

            if ~isfile(pathFile)
                hash = "";
                return
            end

            data = openmebius.infrastructure.filesystem.FileHasher ...
                .readBinaryFile(pathFile);

            switch options.Algorithm
                case "SHA256"
                    hash = utils.sha256_uint8(data);
            end

        end % hashFile

        function saveHashFile(pathFile)

            hash = openmebius.infrastructure.filesystem.FileHasher ...
                .hashFile(pathFile);

            [directory, name, ~] = fileparts(pathFile);
            hashFile = fullfile(directory, name + ".hash");

            fid = fopen(hashFile, "w");

            if fid < 0
                return
            end

            cleanup = onCleanup(@() fclose(fid));
            fprintf(fid, "%s", hash);
            clear cleanup

        end % saveHashFile

    end % methods

    methods (Static, Access = private)

        function data = readBinaryFile(pathFile)

            fid = fopen(pathFile, "rb");

            if fid < 0
                error( ...
                    "OpenMebius2:FileHasher:OpenFailed", ...
                    "Unable to open file: %s", ...
                    pathFile);
            end

            cleanup = onCleanup(@() fclose(fid));
            data = fread(fid, Inf, "*uint8");
            clear cleanup

        end % readBinaryFile

    end % methods

end % classdef
