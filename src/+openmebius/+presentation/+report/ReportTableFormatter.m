classdef ReportTableFormatter
    % REPORTTABLEFORMATTER Converts domain values to readable report text.

    methods (Static)

        function [header, body] = format(data)

            if istimetable(data)
                data = timetable2table(data, 'ConvertRowTimes', true);
            end

            if istable(data)
                header = cellstr(string(data.Properties.VariableNames));
                body = table2cell(data);

                for i = 1:numel(body)
                    body{i} = ...
                        openmebius.presentation.report.ReportTableFormatter ...
                        .formatScalar(body{i});
                end

                rowNames = string(data.Properties.RowNames);

                if ~isempty(rowNames)
                    rowHeader = string(data.Properties.DimensionNames{1});
                    header = [cellstr(rowHeader), header];
                    body = [cellstr(rowNames), body];
                end

                return
            end

            header = cell(0, 0);
            body = ...
                openmebius.presentation.report.ReportTableFormatter ...
                .formatArray(data);

        end % format

    end % methods (Static)

    methods (Static, Access = private)

        function formatted = formatArray(value)

            if iscell(value)
                formatted = cell(size(value));

                for i = 1:numel(value)
                    formatted{i} = ...
                        openmebius.presentation.report.ReportTableFormatter ...
                        .formatScalar(value{i});
                end

                return
            end

            if isstring(value) || ischar(value) || iscategorical(value) || ...
                    isdatetime(value) || isduration(value)
                formatted = cellstr(string(value));
                return
            end

            if isnumeric(value) || islogical(value)
                formatted = cell(size(value));

                for i = 1:numel(value)
                    formatted{i} = ...
                        openmebius.presentation.report.ReportTableFormatter ...
                        .formatScalar(value(i));
                end

                return
            end

            formatted = value;

        end % formatArray

        function textValue = formatScalar(value)

            if isempty(value)
                textValue = '';
            elseif ischar(value)
                textValue = value;
            elseif isstring(value) || iscategorical(value) || ...
                    isdatetime(value) || isduration(value)
                textValue = char(strjoin(string(value(:)), ', '));
            elseif islogical(value) && isscalar(value)

                if value
                    textValue = 'true';
                else
                    textValue = 'false';
                end

            elseif isnumeric(value) && isscalar(value)

                if isfloat(value)
                    textValue = sprintf('%.8g', value);
                else
                    textValue = char(string(value));
                end

            elseif isnumeric(value) || islogical(value)
                textValue = mat2str(value, 8);
            else

                try
                    textValue = char(string(jsonencode(value)));
                catch
                    textValue = ['<', class(value), '>'];
                end

            end

        end % formatScalar

    end % methods (Static, Access = private)

end % classdef
