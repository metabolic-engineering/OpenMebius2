classdef Severity
    % SEVERITY Canonical notification levels and ordering.

    methods (Static)

        function levels = levels()

            levels = [ ...
                "debug", "info", "success", "notice", ...
                "warning", "error", "fatal"];

        end % levels

        function level = normalize(level)

            level = string(level);

            if isempty(level) || ismissing(level(1)) || ...
                    strlength(strtrim(level(1))) == 0
                level = "info";
                return
            end

            level = lower(strtrim(level(1)));

            switch level
                case "debug"
                    level = "debug";
                case {"info", "information"}
                    level = "info";
                case {"ok", "success", "finished", "complete", "completed"}
                    level = "success";
                case "notice"
                    level = "notice";
                case {"warn", "warning"}
                    level = "warning";
                case {"err", "error", "exception"}
                    level = "error";
                case "fatal"
                    level = "fatal";
                otherwise
                    error( ...
                        "OpenMebius2:Severity:InvalidLevel", ...
                        "Unsupported notification level: %s", level);
            end

        end % normalize

        function tf = atLeast(level, threshold)

            levels = openmebius.core.notification.Severity.levels();
            level = openmebius.core.notification.Severity.normalize(level);
            threshold = openmebius.core.notification.Severity ...
                .normalize(threshold);
            tf = find(levels == level, 1) >= ...
                find(levels == threshold, 1);

        end % atLeast

    end % methods (Static)

end % classdef
