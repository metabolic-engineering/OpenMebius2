classdef LegacyResultRepository < handle
    % LEGACYRESULTREPOSITORY
    % Opens the existing IOResult object from a result location.

    methods

        function result = open(~, resultLocation)

            arguments
                ~
                resultLocation openmebius.domain.result.ResultLocation
            end

            result = IOResult(resultLocation);

            if isempty(result) || ~isvalid(result)
                error( ...
                    "OpenMebius2:LegacyProject:InvalidResultObject", ...
                    "Failed to create IOResult.");
            end

            if result.isError
                error( ...
                    "OpenMebius2:LegacyProject:ResultLoadFailed", ...
                    "%s", string(result.statusMsg));
            end

        end % open

    end % methods

end % classdef
