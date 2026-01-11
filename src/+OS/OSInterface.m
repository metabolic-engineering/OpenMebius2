classdef (Abstract) OSInterface < handle

    methods (Abstract, Static)

        tf = isSupported()

    end % methods (Abstract, Static)

    methods (Abstract)

        os = getOperatingSystem(obj)
        cpu = getCPUInfo(obj)
        [ramText, totalGB, typeText] = getRAMInfo(obj)
        path = getCacheDirectory(obj)
        filename = getFileNameForBinary(obj, version)

    end % methods (Abstract)

end % classdef OSInterface
