classdef DirectoryStore
    % DIRECTORYSTORE
    % Small filesystem queries used by repositories and legacy adapters.

    methods (Static)

        function assertDirectoryExists(directory)

            directory = string(directory);

            if ~isfolder(directory)
                error( ...
                    "OpenMebius2:DirectoryStore:DirectoryNotFound", ...
                    "The directory %s does not exist.", ...
                    directory);
            end

        end % assertDirectoryExists

        function files = fileList(directory)

            openmebius.infrastructure.filesystem.DirectoryStore ...
                .assertDirectoryExists(directory);

            listing = dir(string(directory));
            listing = listing(~[listing.isdir]);
            files = string({listing.name});

        end % fileList

        function directories = dirList(directory)

            openmebius.infrastructure.filesystem.DirectoryStore ...
                .assertDirectoryExists(directory);

            listing = dir(string(directory));
            listing = listing([listing.isdir]);
            listing = listing(~ismember({listing.name}, {'.', '..'}));
            directories = string({listing.name});

        end % dirList

        function tf = isEmptyDirectory(directory)

            tf = isempty( ...
                openmebius.infrastructure.filesystem.DirectoryStore.fileList( ...
                directory)) && ...
                isempty( ...
                openmebius.infrastructure.filesystem.DirectoryStore.dirList( ...
                directory));

        end % isEmptyDirectory

    end % methods

end % classdef
