classdef ResultDiffService
    % RESULTDIFFSERVICE Compares saved analysis settings for two results.

    methods

        function comparison = compare(~, result, batchIDs, batchNames)

            arguments
                ~
                result
                batchIDs (:, 1) string
                batchNames (:, 1) string
            end

            if numel(batchIDs) ~= 2 || numel(batchNames) ~= 2
                error( ...
                    "OpenMebius2:ResultDiff:SelectionRequired", ...
                    "Please select exactly two results to compare settings.");
            end

            if numel(unique(batchIDs)) ~= 2
                error( ...
                    "OpenMebius2:ResultDiff:DuplicateSelection", ...
                    "Please select two different results to compare settings.");
            end

            if isempty(result) || ...
                    (isobject(result) && isvalid(result) == false)
                error( ...
                    "OpenMebius2:ResultDiff:ResultUnavailable", ...
                    "Result data is unavailable.");
            end

            try
                snapshots = result.getBatchSnapshots(batchIDs);
            catch
                snapshots = cell(0, 1);
            end

            if ~iscell(snapshots) || numel(snapshots) ~= 2 || ...
                    any(cellfun(@isempty, snapshots))
                error( ...
                    "OpenMebius2:ResultDiff:DataUnavailable", ...
                    "Saved analysis settings are unavailable for one or more selected results.");
            end

            configs = cell(2, 1);

            try

                for resultIndex = 1:2
                    config = openmebius.application.result ...
                        .ResultDiffService.snapshotConfig( ...
                        snapshots{resultIndex});

                    if isempty(config)
                        error( ...
                            "OpenMebius2:ResultDiff:DataUnavailable", ...
                            "Saved analysis settings are unavailable for one or more selected results.");
                    end

                    configs{resultIndex} = openmebius.domain.batch ...
                        .BatchIdentity.semanticConfig(config);
                end

            catch exception

                if startsWith( ...
                        string(exception.identifier), ...
                        "OpenMebius2:ResultDiff:")
                    rethrow(exception);
                end

                error( ...
                    "OpenMebius2:ResultDiff:InvalidData", ...
                    "Saved analysis settings could not be compared: %s", ...
                    string(exception.message));
            end

            differences = openmebius.application.result ...
                .ResultDiffService.compareStructs( ...
                configs{1}, configs{2}, "");
            comparison = openmebius.application.result.ResultDiff( ...
                BatchIDs = batchIDs, ...
                BatchNames = batchNames, ...
                Differences = differences);

        end % compare

    end % methods

    methods (Static, Access = private)

        function config = snapshotConfig(snapshot)

            config = [];

            if ~isstruct(snapshot) || ~isscalar(snapshot) || ...
                    ~isfield(snapshot, "ConfigJson") || ...
                    strlength(string(snapshot.ConfigJson)) == 0
                return
            end

            try
                config = jsondecode(char(string(snapshot.ConfigJson)));
            catch
                config = [];
            end

        end % snapshotConfig

        function differences = compareStructs(first, second, prefix)

            differences = strings(0, 1);
            fields = unique([ ...
                string(fieldnames(first)); ...
                string(fieldnames(second))]);

            for fieldIndex = 1:numel(fields)
                field = fields(fieldIndex);
                path = field;

                if prefix ~= ""
                    path = prefix + "." + field;
                end

                hasFirst = isfield(first, field);
                hasSecond = isfield(second, field);

                if ~hasFirst
                    differences(end + 1, 1) = ...
                        path + ": <missing> -> " + ...
                        openmebius.application.result ...
                        .ResultDiffService.formatValue( ...
                        second.(field)); %#ok<AGROW>
                    continue
                elseif ~hasSecond
                    differences(end + 1, 1) = ...
                        path + ": " + ...
                        openmebius.application.result ...
                        .ResultDiffService.formatValue(first.(field)) + ...
                        " -> <missing>"; %#ok<AGROW>
                    continue
                end

                firstValue = first.(field);
                secondValue = second.(field);

                if isstruct(firstValue) && isscalar(firstValue) && ...
                        isstruct(secondValue) && isscalar(secondValue)
                    nested = openmebius.application.result ...
                        .ResultDiffService.compareStructs( ...
                        firstValue, secondValue, path);
                    differences = [differences; nested]; %#ok<AGROW>
                elseif ~openmebius.application.result ...
                        .ResultDiffService.equivalentValues( ...
                        firstValue, secondValue)
                    differences(end + 1, 1) = ...
                        path + ": " + ...
                        openmebius.application.result ...
                        .ResultDiffService.formatValue(firstValue) + ...
                        " -> " + ...
                        openmebius.application.result ...
                        .ResultDiffService.formatValue(secondValue); %#ok<AGROW>
                end

            end

        end % compareStructs

        function text = formatValue(value)

            if isempty(value)
                text = "[]";
            elseif ischar(value)
                text = """" + string(value) + """";
            elseif isstring(value) || iscellstr(value)
                quoted = """" + string(value(:)) + """";

                if isscalar(quoted)
                    text = quoted;
                else
                    text = "[" + strjoin(quoted, ", ") + "]";
                end

            elseif isnumeric(value) || islogical(value)
                text = string(mat2str(value));
            else

                try
                    text = string(jsonencode(value));
                catch
                    text = "<unavailable>";
                end

            end

        end % formatValue

        function tf = equivalentValues(first, second)

            if isempty(first) && isempty(second)
                tf = true;
                return
            end

            if (isnumeric(first) || islogical(first)) && ...
                    (isnumeric(second) || islogical(second))

                if isvector(first) && isvector(second)
                    tf = isequaln(double(first(:)), double(second(:)));
                else
                    tf = isequaln(double(first), double(second));
                end

                return
            end

            isFirstText = ischar(first) || isstring(first) || ...
                iscellstr(first);
            isSecondText = ischar(second) || isstring(second) || ...
                iscellstr(second);

            if isFirstText && isSecondText
                tf = isequaln(string(first(:)), string(second(:)));
                return
            end

            tf = isequaln(first, second);

        end % equivalentValues

    end % methods (Static, Access = private)

end % classdef
