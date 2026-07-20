classdef IdentifierFormatter
    % IDENTIFIERFORMATTER Formats stable identifiers for UI display.

    methods (Static)

        function value = short(value)

            value = string(value);
            maximumLength = 10;
            lengths = strlength(value);
            mask = lengths > maximumLength;
            value(mask) = extractBefore(value(mask), maximumLength + 1);

        end

    end

end
