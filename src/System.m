classdef System < handle

    methods

        function obj = System()
            % SYSTEM Constructor for System class
        end % function obj = System()

    end % methods

    methods (Static)

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
