classdef FileProjectRepository < handle

    methods

        function session = openProject(~, projectDirectory)

            arguments
                ~
                projectDirectory (1, 1) string
            end

            paths = openmebius.domain.project.ProjectPaths( ...
                projectDirectory);

            paths.assertExists();

            metadata = ...
                openmebius.infrastructure.project.FileProjectRepository ...
                .readMetadata(paths.SettingFile);

            openmebius.infrastructure.project.FileProjectRepository ...
                .ensureLayout(paths);

            session = openmebius.domain.project.ProjectSession( ...
                metadata, ...
                paths);

        end

        function saveProject(~, session)

            arguments
                ~
                session openmebius.domain.project.ProjectSession
            end

            data = session.Metadata.toStruct();

            text = jsonencode(data, PrettyPrint = true);

            fid = fopen(session.Paths.SettingFile, "w");

            if fid < 0
                error( ...
                    "OpenMebius2:Project:SettingFileWriteFailed", ...
                    "Could not open setting.json for writing: %s", ...
                    session.Paths.SettingFile);
            end

            cleanup = onCleanup(@() fclose(fid));
            fprintf(fid, "%s", text);

        end

    end

    methods (Static)

        function metadata = readMetadata(settingFile)

            fid = fopen(settingFile, "r");

            if fid < 0
                error( ...
                    "OpenMebius2:Project:SettingFileReadFailed", ...
                    "Could not open setting.json: %s", ...
                    settingFile);
            end

            cleanup = onCleanup(@() fclose(fid));

            raw = fread(fid, inf, "*char")';
            data = jsondecode(raw);

            metadata = ...
                openmebius.domain.project.ProjectMetadata.fromStruct(data);

        end % method readMetadata

        function ensureLayout(paths)

            folders = [
                       paths.ModelDirectory
                       paths.ExperimentDirectory
                       paths.ResultDirectory
                       ];

            for i = 1:numel(folders)

                if ~isfolder(folders(i))
                    mkdir(folders(i));
                end

            end

        end % method ensureLayout

    end % methods (Static)

end % classdef
