classdef ResultViewMode

    methods (Static)

        function mode = normalize(value)

            value = lower(strtrim(string(value)));

            switch value

                case "overview"
                    mode = "Overview";

                case {"mdv", "details", "detailed"}
                    mode = "MDV";

                case {"mdv (summary)", "mdv summary", "mdv-summary"}
                    mode = "MDV (Summary)";

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
