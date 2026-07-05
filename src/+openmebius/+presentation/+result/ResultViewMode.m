classdef ResultViewMode

    methods (Static)

        function mode = normalize(value)

            value = lower(strtrim(string(value)));

            switch value

                case "overview"
                    mode = "Overview";

                case {"details", "detailed"}
                    mode = "Details";

                case "comparison"
                    mode = "Comparison";

                otherwise
                    error( ...
                        "OpenMebius2:Result:InvalidViewMode", ...
                        "Unknown result view mode: %s", value);
            end

        end

    end

end
