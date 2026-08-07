classdef LegacyPlainTextCodeParserStub < handle

    methods

        function codeData = parseCodeData( ...
                ~, componentCallbackAssignments, startupName, isSingleton)

            codeData = struct( ...
                ComponentCallbackAssignments = ...
                componentCallbackAssignments, ...
                StartupName = startupName, ...
                IsSingleton = isSingleton);

        end

    end

end
