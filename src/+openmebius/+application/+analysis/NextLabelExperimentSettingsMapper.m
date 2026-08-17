classdef NextLabelExperimentSettingsMapper
    % NEXTLABELEXPERIMENTSETTINGSMAPPER Maps Batch suggestion fields.

    methods (Static)

        function settings = fromBatchConfig(config)

            arguments
                config (1, 1) struct
            end

            defaults = openmebius.domain.batch.BatchConfig.defaultConfig();
            patterns = openmebius.application.analysis ...
                .NextLabelExperimentSettingsMapper.toPatternMatrix( ...
                openmebius.application.analysis ...
                .NextLabelExperimentSettingsMapper.valueOrDefault( ...
                config, 'suggestionTable', defaults.suggestionTable));
            patternNames = openmebius.application.analysis ...
                .NextLabelExperimentSettingsMapper.toNameVector( ...
                openmebius.application.analysis ...
                .NextLabelExperimentSettingsMapper.valueOrDefault( ...
                config, 'suggestionTableRowNames', ...
                defaults.suggestionTableRowNames), ...
                "suggestionTableRowNames");
            tracerNames = openmebius.application.analysis ...
                .NextLabelExperimentSettingsMapper.toNameVector( ...
                openmebius.application.analysis ...
                .NextLabelExperimentSettingsMapper.valueOrDefault( ...
                config, 'suggestionTableVarNames', ...
                defaults.suggestionTableVarNames), ...
                "suggestionTableVarNames");
            settings = openmebius.mfa.NextLabelExperimentSettings( ...
                Patterns = patterns, ...
                PatternNames = patternNames, ...
                TracerNames = tracerNames);

        end

    end

    methods (Static, Access = private)

        function values = toPatternMatrix(value)

            if isstring(value)
                values = value;
                return
            end

            if ischar(value)

                if isempty(value)
                    values = strings(0, 0);
                elseif isrow(value)
                    values = string(value);
                else
                    values = string(cellstr(value));
                end

                return
            end

            if iscell(value)
                values = strings(size(value));

                for i = 1:numel(value)
                    candidate = value{i};

                    if isempty(candidate)
                        values(i) = "";
                    elseif (ischar(candidate) && isrow(candidate)) || ...
                            (isstring(candidate) && isscalar(candidate))
                        values(i) = string(candidate);
                    else
                        openmebius.application.analysis ...
                            .NextLabelExperimentSettingsMapper ...
                            .invalidPatternValue();
                    end

                end

                return
            end

            if isempty(value)
                values = strings(0, 0);
                return
            end

            openmebius.application.analysis ...
                .NextLabelExperimentSettingsMapper.invalidPatternValue();

        end

        function names = toNameVector(value, fieldName)

            if isempty(value)
                names = strings(0, 1);
                return
            end

            if ~(ischar(value) || isstring(value) || iscellstr(value))
                error( ...
                    "OpenMebius2:NextLabelExperimentSettingsMapper:" + ...
                    "InvalidNames", ...
                    "%s must contain text values.", fieldName);
            end

            names = string(value(:));

        end

        function value = valueOrDefault(config, fieldName, defaultValue)

            value = defaultValue;

            if isfield(config, fieldName) && ~isempty(config.(fieldName))
                value = config.(fieldName);
            end

        end

        function invalidPatternValue()

            error( ...
                "OpenMebius2:NextLabelExperimentSettingsMapper:" + ...
                "InvalidPatternValue", ...
                "Suggestion patterns must contain scalar text values " + ...
                "or empty cells.");

        end

    end

end
