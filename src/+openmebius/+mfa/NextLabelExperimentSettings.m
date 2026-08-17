classdef NextLabelExperimentSettings
    % NEXTLABELEXPERIMENTSETTINGS Validated next-label candidate patterns.

    properties (SetAccess = private)
        Patterns (:, :) string
        PatternNames (:, 1) string
        TracerNames (1, :) string
    end

    methods

        function obj = NextLabelExperimentSettings(options)

            arguments
                options.Patterns string = strings(0, 0)
                options.PatternNames string = strings(0, 1)
                options.TracerNames string = strings(1, 0)
            end

            patterns = options.Patterns;
            patternNames = options.PatternNames(:);
            tracerNames = options.TracerNames(:).';

            if isempty(patterns) && size(patterns, 2) == 0 && ...
                    ~isempty(tracerNames)
                patterns = strings(0, numel(tracerNames));
            end

            if size(patterns, 2) ~= numel(tracerNames)
                error( ...
                    "OpenMebius2:NextLabelExperimentSettings:" + ...
                    "TracerCountMismatch", ...
                    "Candidate pattern columns must match tracer names.");
            end

            if ~isempty(patternNames) && ...
                    size(patterns, 1) ~= numel(patternNames)
                error( ...
                    "OpenMebius2:NextLabelExperimentSettings:" + ...
                    "PatternCountMismatch", ...
                    "Candidate pattern rows must match pattern names.");
            end

            if any(ismissing(tracerNames)) || ...
                    any(strlength(strtrim(tracerNames)) == 0)
                error( ...
                    "OpenMebius2:NextLabelExperimentSettings:" + ...
                    "InvalidTracerName", ...
                    "Tracer names must be nonempty strings.");
            end

            if numel(unique(tracerNames)) ~= numel(tracerNames)
                error( ...
                    "OpenMebius2:NextLabelExperimentSettings:" + ...
                    "DuplicateTracerName", ...
                    "Tracer names must be unique.");
            end

            obj.Patterns = patterns;
            obj.PatternNames = patternNames;
            obj.TracerNames = tracerNames;

        end

        function value = patternCount(obj)

            value = size(obj.Patterns, 1);

        end

        function pattern = patternAt(obj, index)

            arguments
                obj (1, 1) openmebius.mfa.NextLabelExperimentSettings
                index (1, 1) double {mustBeInteger, mustBePositive}
            end

            if index > obj.patternCount()
                error( ...
                    "OpenMebius2:NextLabelExperimentSettings:" + ...
                    "PatternIndexOutOfRange", ...
                    "Candidate pattern index is out of range.");
            end

            pattern = obj.Patterns(index, :);

        end

        function value = isCompletePattern(obj, index)

            pattern = obj.patternAt(index);
            value = all(~ismissing(pattern));

            if value
                value = all(strlength(strtrim(pattern)) > 0);
            end

        end

    end

end
