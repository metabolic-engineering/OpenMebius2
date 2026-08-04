classdef MFAExperimentListNormalizer
    % MFAEXPERIMENTLISTNORMALIZER
    % Normalizes legacy experiment-list inputs to a column representation.

    methods

        function experimentList = normalize(~, value)

            while iscell(value) && isscalar(value)
                value = value{1};
            end

            if iscell(value)
                experimentList = string(value(:));
            elseif isstring(value)
                experimentList = value(:);
            elseif ischar(value)
                experimentList = string(value);
            elseif isnumeric(value)
                experimentList = value(:);
            else
                error( ...
                    "OpenMebius2:MFAExperimentListNormalizer:" + ...
                    "InvalidExperimentList", ...
                    "Experiment list must contain text or numeric " + ...
                "identifiers.");
            end

        end % normalize

    end % methods

end % classdef
