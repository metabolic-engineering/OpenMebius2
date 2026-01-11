classdef WindowsOS < OS.OSInterface

    methods (Static)

        function tf = isSupported()
            tf = ispc;
        end % function isSupported

    end % methods (Static)

    methods

        function os = getOperatingSystem(~)
            os = "Windows";
        end % function getOperatingSystem

        function cpu = getCPUInfo(~)
            % GETCPUINFO Returns information about the CPU on Windows OS
            %
            %   cpu = getCPUInfo() returns a structure containing information
            %   about the CPU, such as its name, number of cores, and clock speed.

            cmd = 'powershell -Command "Get-CimInstance Win32_Processor | Select-Object -ExpandProperty Name"';

            [status, cpu] = system(cmd);

            cpu = strtrim(cpu);

            if status ~= 0 || isempty(cpu)
                cpu = "Unknown CPU";
            end

            cpu = string(cpu);

        end % function getCPUInfo

        function [ramText, totalGB, typeText] = getRAMInfo(~)

            ps = [
                  'powershell -NoProfile -Command "' ...
                      '$m=Get-CimInstance Win32_PhysicalMemory; ' ...
                      '$total=($m|Measure-Object -Property Capacity -Sum).Sum; ' ...
                      '$type=($m|Select-Object -First 1 -ExpandProperty SMBIOSMemoryType); ' ...
                      '$type2=($m|Select-Object -First 1 -ExpandProperty MemoryType); ' ...
                      '$speed=($m|Select-Object -First 1 -ExpandProperty Speed); ' ...
                      'Write-Output ($total.ToString()+''|''+$type.ToString()+''|''+$type2.ToString()+''|''+$speed.ToString())' ...
                      '"'
                  ];

            [status, out] = system(ps);

            if status ~= 0
                totalGB = NaN;
                typeText = "Unknown";
                ramText = "Unknown RAM";
                return;
            end

            parts = split(strtrim(string(out)), "|");
            totalBytes = str2double(parts(1));
            smbiosType = str2double(parts(2));
            memoryType = str2double(parts(3));
            speed = str2double(parts(4));

            totalGB = totalBytes / 1024 ^ 3;

            switch smbiosType
                case 20, typeText = "DDR";
                case 21, typeText = "DDR2";
                case 24, typeText = "DDR3";
                case 26, typeText = "DDR4";
                case 34, typeText = "DDR5";
                otherwise , typeText = "Unknown";
            end

            if typeText == "Unknown"

                switch memoryType
                    case 20, typeText = "DDR";
                    case 21, typeText = "DDR2";
                    case 24, typeText = "DDR3";
                    case 26, typeText = "DDR4";
                    case 34, typeText = "DDR5";
                    otherwise , typeText = "Unknown";
                end

            end

            if isnan(speed) || speed <= 0
                ramText = sprintf("%s %.1f GB", typeText, totalGB);
            else
                ramText = sprintf("%s %.1f GB (%g MT/s)", typeText, totalGB, speed);
            end

        end % function getRAMInfo

        function path = getCacheDirectory(~)
            % GETCACHEDIRECTORY Returns the path to the cache directory on Windows OS

            path = string(fullfile(getenv('APPDATA'), 'OpenMebius2', 'logs'));

        end % function path = getCacheDirectory

        function filename = getFileNameForBinary(~, version)
            % GETFILENAMEFORBINARY Returns the filename for a binary on Windows OS
            %
            %   filename = getFileNameForBinary(name) returns the appropriate
            %   filename for the given binary name on Windows OS.

            filename = "openmebius2-v" + version + "-windows-x86-64";

        end % function filename = getFileNameForBinary

    end % methods

end % classdef WindowsOS
