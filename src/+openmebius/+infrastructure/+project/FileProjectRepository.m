classdef FileProjectRepository < handle

    methods

        function session = openProject(~, projectInput)

            arguments
                ~
                projectInput (1, 1) string
            end

            projectDirectory = ...
                openmebius.infrastructure.project.FileProjectRepository ...
                .resolveProjectDirectory(projectInput);

            paths = openmebius.domain.project.ProjectPaths( ...
                projectDirectory);

            paths.assertExists();

            metadata = ...
                openmebius.infrastructure.project.FileProjectRepository ...
                .readMetadata(paths.activeSettingFile());

            openmebius.infrastructure.project.FileProjectRepository ...
                .ensureLayout(paths);

            session = openmebius.domain.project.ProjectSession( ...
                metadata, ...
                paths);

        end % method openProject

        function saveProject(~, session)

            arguments
                ~
                session openmebius.domain.project.ProjectSession
            end

            data = session.Metadata.toStruct();

            openmebius.infrastructure.project.FileProjectRepository ...
                .writeMetadata(session.Paths.SettingFile, data);
            openmebius.infrastructure.project.FileProjectRepository ...
                .writeMetadata(session.Paths.LegacySettingFile, data);

        end % method saveProject

    end % methods

    methods (Static)

        function projectDirectory = resolveProjectDirectory(projectInput)

            projectInput = strtrim(string(projectInput));

            if projectInput == ""
                error( ...
                    "OpenMebius2:Project:EmptyProjectInput", ...
                "Project path is empty.");
            end

            if isfolder(projectInput)
                projectDirectory = projectInput;
                return
            end

            if isfile(projectInput)

                if openmebius.domain.project.ProjectLayout.isSettingFile( ...
                        projectInput)

                    projectDirectory = string(fileparts(projectInput));
                    return
                end

                error( ...
                    "OpenMebius2:Project:UnsupportedProjectFile", ...
                    "Unsupported project file: %s", projectInput);
            end

            [parentDirectory, fileName, ext] = fileparts(projectInput);
            candidate = fileName + ext;

            if any(strcmpi( ...
                    candidate, ...
                    openmebius.domain.project.ProjectLayout.settingFileNames()))

                projectDirectory = string(parentDirectory);
                return
            end

            error( ...
                "OpenMebius2:Project:ProjectPathNotFound", ...
                "Project path does not exist: %s", projectInput);

        end % method resolveProjectDirectory

        function metadata = readMetadata(settingFile)

            fid = fopen(settingFile, "r");

            if fid < 0
                error( ...
                    "OpenMebius2:Project:SettingFileReadFailed", ...
                    "Could not open project setting file: %s", ...
                    settingFile);
            end

            cleanup = onCleanup(@() fclose(fid));

            raw = fread(fid, inf, "*char")';
            data = jsondecode(raw);

            metadata = ...
                openmebius.domain.project.ProjectMetadata.fromStruct(data);

        end % method readMetadata

        function writeMetadata(settingFile, data)

            text = jsonencode(data, PrettyPrint = true);

            parentDirectory = string(fileparts(settingFile));

            if parentDirectory ~= "" && ~isfolder(parentDirectory)
                mkdir(parentDirectory);
            end

            temporaryFile = string(tempname(parentDirectory)) + ".tmp";

            fid = fopen(temporaryFile, "w");

            if fid < 0
                error( ...
                    "OpenMebius2:Project:SettingFileWriteFailed", ...
                    "Could not open project setting file for writing: %s", ...
                    settingFile);
            end

            cleanup = onCleanup(@() ...
                openmebius.infrastructure.project.FileProjectRepository ...
                .cleanupTemporaryFile(fid, temporaryFile));

            fprintf(fid, "%s", text);
            fclose(fid);

            [ok, msg] = movefile(temporaryFile, settingFile, "f");

            if ~ok
                error( ...
                    "OpenMebius2:Project:SettingFileReplaceFailed", ...
                    "Could not replace project setting file: %s", ...
                    string(msg));
            end

        end % method writeMetadata

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

        function cleanupTemporaryFile(fid, temporaryFile)

            try
                fclose(fid);
            catch
            end

            try

                if isfile(temporaryFile)
                    delete(temporaryFile);
                end

            catch
            end

        end % method cleanupTemporaryFile

    end % methods (Static)

end % classdef
