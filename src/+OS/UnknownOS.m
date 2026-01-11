classdef UnknownOS < OS.OSInterface

    methods (Static)

        function tf = isSupported()
            tf = true;
        end % function isSupported

    end % methods (Static)

    methods

        function os = getOperatingSystem(~)
            os = "Unknown";
        end % function getOperatingSystem

        function cpu = getCPUInfo(~)
            % GETCPUINFO Returns information about the CPU on Unknown OS
            %
            %   cpu = getCPUInfo() returns a structure containing information
            %   about the CPU, such as its name, number of cores, and clock speed.

            cpu = "Unknown CPU";

        end % function getCPUInfo

        function [ramText, totalGB, typeText] = getRAMInfo(~)
            % GETRAMINFO Returns information about the RAM on Unknown OS
            %
            %   [ramText, totalGB, typeText] = getRAMInfo() returns a string
            %   describing the RAM, the total size in GB, and the type of RAM.

            totalGB = NaN;
            typeText = "Unknown";
            ramText = "Unknown RAM";

        end % function getRAMInfo

        function path = getCacheDirectory(~)
            % GETCACHEDIRECTORY Returns the cache directory path for Unknown OS

            path = "";

        end % function path = getCacheDirectory

        function filename = getFileNameForBinary(~, version)
            % GETFILENAMEFORBINARY Returns the filename for a binary on Unknown OS
            %
            %   filename = getFileNameForBinary(name) returns the appropriate
            %   filename for the given binary name on Unknown OS.

            filename = "openmebius2-v" + version + "-unknown-os-x86_64";

        end % function filename = getFileNameForBinary

    end % methods

end % classdef UnknownOS
