classdef LinuxOS < OS.OSInterface

    methods (Static)

        function tf = isSupported()
            tf = isunix && ~ismac;
        end % function isSupported

    end % methods (Static)

    methods

        function os = getOperatingSystem(~)
            os = "Linux";
        end % function getOperatingSystem

        function cpu = getCPUInfo(~)
            % GETCPUINFO Returns information about the CPU on Linux
            %
            %   cpu = getCPUInfo() returns a structure containing information
            %   about the CPU, such as its name, number of cores, and clock speed.

            cpu = "Unknown CPU";

            try
                fid = fopen('/proc/cpuinfo', 'r');

                if fid ~= -1
                    cpuInfo = fread(fid, '*char')';
                    fclose(fid);

                    lines = strsplit(cpuInfo, '\n');

                    for i = 1:length(lines)
                        line = strtrim(lines{i});

                        if startsWith(line, 'model name')
                            parts = strsplit(line, ':');

                            if length(parts) == 2
                                cpu = strtrim(parts{2});
                                break;
                            end

                        end

                    end

                end

            catch
                % If any error occurs, return "Unknown CPU"
                cpu = "Unknown CPU";
            end

            cpu = string(cpu);

        end % function getCPUInfo

        function [ramText, totalGB, typeText] = getRAMInfo(~)
            % GETRAMINFO Returns information about the RAM on Linux
            %
            %   [ramText, totalGB, typeText] = getRAMInfo() returns a string
            %   describing the RAM, the total size in GB, and the type of RAM.

            ramText = "Unknown RAM";
            totalGB = NaN;
            typeText = "Unknown";

            try
                fid = fopen('/proc/meminfo', 'r');

                if fid ~= -1
                    memInfo = fread(fid, '*char')';
                    fclose(fid);

                    lines = strsplit(memInfo, '\n');

                    for i = 1:length(lines)
                        line = strtrim(lines{i});

                        if startsWith(line, 'MemTotal:')
                            parts = strsplit(line);

                            if length(parts) >= 2
                                totalKB = str2double(parts{2});
                                totalGB = totalKB / (1024 * 1024);
                                ramText = sprintf('%.2f GB', totalGB);
                                break;
                            end

                        end

                    end

                end

            catch
                % If any error occurs, return unknown values
                ramText = "Unknown RAM";
                totalGB = NaN;
                typeText = "Unknown";
            end

        end % function getRAMInfo

        function path = getCacheDirectory(~)
            % GETCACHEDIRECTORY Returns the cache directory path for Linux

            path = string(fullfile(getenv('HOME'), '.config', 'OpenMebius2', 'logs'));

        end % function path = getCacheDirectory

        function filename = getFileNameForBinary(~, version)
            % GETFILENAMEFORBINARY Returns the filename for a binary on Linux
            %
            %   filename = getFileNameForBinary(name) returns the appropriate
            %   filename for the given binary name on Linux.

            filename = "openmebius2-v" + version + "-linux-x86_64";

        end % function filename = getFileNameForBinary

    end % methods

end % classdef LinuxOS
