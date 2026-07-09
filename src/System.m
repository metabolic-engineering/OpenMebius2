classdef System < handle

    methods

        function obj = System()
            % SYSTEM Constructor for System class
        end % function obj = System()

    end % methods

    methods (Static)

        function version = getCurrentVersion()
            % GETCURRENTVERSION Returns the version of this application build.
            % Update this value when creating a new release tag.

            version = "2.4.2";

        end % function version = getCurrentVersion()

        function [latestVersion, releaseURL] = getLatestOpenMebius2Version()
            % GETLATESTOPENMEBIUS2VERSION Returns the latest public GitHub version.
            % This method does not require git to be installed. It is intended for
            % runtime update checks in deployed applications.

            repo = "metabolic-engineering/OpenMebius2";
            releaseURL = "https://github.com/" + repo + "/releases";

            opts = weboptions( ...
                "Timeout", 3, ...
                "HeaderFields", {'User-Agent', 'OpenMebius2'} ...
            );

            latestVersion = "";

            try
                url = "https://api.github.com/repos/" + repo + "/releases/latest";
                data = webread(url, opts);

                if isfield(data, "tag_name") && strlength(string(data.tag_name)) > 0
                    latestVersion = System.normalizeVersion(data.tag_name);
                end

                if isfield(data, "html_url") && strlength(string(data.html_url)) > 0
                    releaseURL = string(data.html_url);
                end

            catch
                latestVersion = "";
            end

            % Fall back to tags because this repository may use tags without releases.
            if strlength(latestVersion) == 0
                url = "https://api.github.com/repos/" + repo + "/tags?per_page=100";
                data = webread(url, opts);

                if isempty(data)
                    error("OpenMebius2:UpdateCheck:NoTags", "No GitHub tags were found.");
                end

                tagNames = strings(numel(data), 1);

                for i = 1:numel(data)
                    tagNames(i) = System.normalizeVersion(data(i).name);
                end

                latestVersion = System.getNewestVersion(tagNames);
            end

        end % function [latestVersion, releaseURL] = getLatestOpenMebius2Version()

        function tf = isVersionNewer(candidateVersion, currentVersion)
            % ISVERSIONNEWER True if candidateVersion is newer than currentVersion.

            candidate = System.parseVersion(candidateVersion);
            current = System.parseVersion(currentVersion);

            n = max(numel(candidate), numel(current));
            candidate(end + 1:n) = 0;
            current(end + 1:n) = 0;

            diffVersion = candidate - current;
            idx = find(diffVersion ~= 0, 1, "first");

            tf = ~isempty(idx) && diffVersion(idx) > 0;

        end % function tf = isVersionNewer(candidateVersion, currentVersion)

        function version = normalizeVersion(version)
            % NORMALIZEVERSION Removes a leading v/V from semantic version tags.

            version = string(regexprep(char(string(version)), "^[vV]", ""));

        end % function version = normalizeVersion(version)

        function os = getOperatingSystem(~)
            % GETOPERATINGSYSTEM Returns the current operating system as a string

            impl = System.getOS();
            os = impl.getOperatingSystem();

        end % function os = getOperatingSystem()

        function cpu = getCPUInfo()
            % GETCPUINFO Returns information about the CPU

            impl = System.getOS();
            cpu = impl.getCPUInfo();

        end % function cpu = getCPUInfo()

        function [ramText, totalGB, typeText] = getRAMInfo()
            % GETRAMINFO Returns information about the RAM

            impl = System.getOS();
            [ramText, totalGB, typeText] = impl.getRAMInfo();

        end % function ram = getRAMInfo()

        function path = getCacheDirectory()
            % GETCACHEDIRECTORY Returns the cache directory path

            impl = System.getOS();
            path = impl.getCacheDirectory();

        end % function path = getCacheDirectory()

        function filename = getFileNameForBinary(version)
            % GETFILENAMEFORBINARY Returns the filename for the binary corresponding to the given version

            impl = System.getOS();
            filename = impl.getFileNameForBinary(version);

        end % function name = getFileNameForBinary()

        function tag = getLatestTag()
            % GETLATESTRELEASETAG Returns the latest release tag from GitHub

            [status, tag] = system('git tag --sort=-v:refname');

            if status ~= 0 || isempty(strtrim(tag))
                error('No git tags found.');
            end

            tags = splitlines(strtrim(tag));
            tag = string(tags{1});

        end % function tag = getLatestReleaseTag()

        function dockername = getDockerImageName()
            % GETDOCKERIMAGENAME Returns the Docker image name for the current OS

            tag = System.getLatestTag();
            dockername = "openmebius2:v" + tag;

        end % function dockername = getDockerImageName()

    end

    methods (Access = private, Static)

        function values = parseVersion(version)
            % PARSEVERSION Extracts numeric components from a version string.

            tokens = regexp(char(System.normalizeVersion(version)), "\d+", "match");

            if isempty(tokens)
                values = 0;
                return
            end

            values = str2double(tokens);
            values(isnan(values)) = 0;

        end % function values = parseVersion(version)

        function newest = getNewestVersion(versions)
            % GETNEWESTVERSION Returns the newest version from a string array.

            versions = string(versions);
            versions = versions(strlength(versions) > 0);

            if isempty(versions)
                error("OpenMebius2:UpdateCheck:NoVersions", "No versions were found.");
            end

            newest = versions(1);

            for i = 2:numel(versions)

                if System.isVersionNewer(versions(i), newest)
                    newest = versions(i);
                end

            end

        end % function newest = getNewestVersion(versions)

        function impl = getOS()

            classes = {OS.WindowsOS, OS.MacOS, OS.LinuxOS};

            impl = OS.UnknownOS();

            for k = 1:length(classes)
                cls = classes{k};

                if cls.isSupported()
                    impl = cls();
                    return;
                end

            end

        end % function impl = getOS()

    end % methods (Access = private, Static)

end % classdef System < handle
