classdef MacOS < OS.OSInterface

    methods (Static)

        function tf = isSupported()
            tf = ismac;
        end % function isSupported

    end % methods (Static)

    methods

        function os = getOperatingSystem(~)
            os = "MacOS";
        end % function getOperatingSystem

        function cpu = getCPUInfo(~)
            % GETCPUINFO Returns information about the CPU on MacOS
            %
            %   cpu = getCPUInfo() returns a structure containing information
            %   about the CPU, such as its name, number of cores, and clock speed.

            [status, cpu] = system('sysctl -n machdep.cpu.brand_string');

            cpu = strtrim(cpu);

            if status ~= 0 || isempty(cpu)
                cpu = "Unknown CPU";
            end

            cpu = string(cpu);

        end % function getCPUInfo

        function [ramText, totalGB, typeText] = getRAMInfo(~)
            % GETRAMINFO Returns information about the RAM on MacOS
            %
            %   [ramText, totalGB, typeText] = getRAMInfo() returns a string
            %   describing the RAM, the total size in GB, and the type of RAM.

            [statusSize, sizeOut] = system('sysctl -n hw.memsize');
            [statusType, typeOut] = system('system_profiler SPMemoryDataType | grep "Type:" | head -n 1');

            if statusSize ~= 0 || isempty(sizeOut)
                totalGB = NaN;
                ramText = "Unknown RAM";
            else
                totalBytes = str2double(strtrim(sizeOut));
                totalGB = totalBytes / (1024 ^ 3);
                ramText = sprintf('%.2f GB', totalGB);
            end

            if statusType ~= 0 || isempty(typeOut)
                typeText = "Unknown";
            else
                parts = strsplit(strtrim(typeOut), ':');

                if length(parts) == 2
                    typeText = strtrim(parts{2});
                else
                    typeText = "Unknown";
                end

            end

        end % function getRAMInfo

        function path = getCacheDirectory(~)
            % GETCACHEDIRECTORY Returns the path to the cache directory on MacOS

            path = string(fullfile(getenv('HOME'), 'Library', 'Application Support', 'OpenMebius2', 'logs'));

        end % function path = getCacheDirectory

        function filename = getFileNameForBinary(~, version)
            % GETFILENAMEFORBINARY Returns the filename for a binary on MacOS
            %
            %   filename = getFileNameForBinary(name) returns the appropriate
            %   filename for the given binary name on MacOS.

            filename = "openmebius2-v" + version + "-macos-x86_64";

        end % function filename = getFileNameForBinary

    end % methods

end % classdef MacOS
