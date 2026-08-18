classdef ResultInformationService
    % RESULTINFORMATIONSERVICE Builds execution information for one result.

    methods

        function information = load( ...
                ~, result, batchIDs, batchNames, modelDegreesOfFreedom)

            arguments
                ~
                result
                batchIDs (:, 1) string
                batchNames (:, 1) string
                modelDegreesOfFreedom (1, 1) double
            end

            if numel(batchIDs) ~= 1 || numel(batchNames) ~= 1
                error( ...
                    "OpenMebius2:ResultInformation:SelectionRequired", ...
                    "Please select exactly one result to view information.");
            end

            if isempty(result) || ...
                    (isobject(result) && isvalid(result) == false)
                error( ...
                    "OpenMebius2:ResultInformation:ResultUnavailable", ...
                    "Result data is unavailable.");
            end

            [loaded, mask] = result.loadResultFiles( ...
                batchIDs.', readstatus = [true, true, false, false]);

            if isempty(mask) || ~mask(1) || isempty(loaded{1})
                error( ...
                    "OpenMebius2:ResultInformation:DataUnavailable", ...
                    "Information for the selected result is unavailable.");
            end

            data = loaded{1};
            snapshot = openmebius.application.result ...
                .ResultInformationService.snapshotFor( ...
                result, batchIDs(1));
            config = openmebius.application.result ...
                .ResultInformationService.snapshotConfig(snapshot);
            [differentSettings, settingsAvailable] = ...
                openmebius.application.result.ResultInformationService ...
                .differentSettings(config);
            hasEfflux = openmebius.application.result ...
                .ResultInformationService.hasEfflux(config);
            mdvRSS = openmebius.application.result ...
                .ResultInformationService.mdvRSSContribution(data);
            totalRSS = openmebius.application.result ...
                .ResultInformationService.minimumRSS(data);
            effluxRSS = NaN;

            if hasEfflux && isfinite(mdvRSS) && isfinite(totalRSS)
                effluxRSS = totalRSS - mdvRSS;
                tolerance = 1e-9 * max([1, abs(totalRSS), abs(mdvRSS)]);

                if effluxRSS < 0 && abs(effluxRSS) <= tolerance
                    effluxRSS = 0;
                elseif effluxRSS < 0
                    effluxRSS = NaN;
                end

            end

            batchName = openmebius.application.result ...
                .ResultInformationService.snapshotString( ...
                snapshot, "Name", batchNames(1));
            information = openmebius.application.result.ResultInformation( ...
                BatchID = batchIDs(1), ...
                BatchName = batchName, ...
                Description = openmebius.application.result ...
                .ResultInformationService.snapshotString( ...
                snapshot, "Description", ""), ...
                ExperimentNames = ...
                openmebius.application.result.ResultInformationService ...
                .snapshotExperiments(snapshot), ...
                StartedAtUtc = openmebius.application.result ...
                .ResultInformationService.snapshotString( ...
                snapshot, "StartedAtUtc", ""), ...
                FinishedAtUtc = openmebius.application.result ...
                .ResultInformationService.snapshotString( ...
                snapshot, "FinishedAtUtc", ""), ...
                ElapsedSeconds = openmebius.application.result ...
                .ResultInformationService.elapsedSeconds( ...
                snapshot), ...
                DifferentSettings = differentSettings, ...
                SettingsAvailable = settingsAvailable, ...
                MDVDegreesOfFreedom = ...
                openmebius.application.result.ResultInformationService ...
                .mdvDegreesOfFreedom(data), ...
                EffluxDegreesOfFreedom = ...
                openmebius.application.result.ResultInformationService ...
                .effluxDegreesOfFreedom(config), ...
                ModelDegreesOfFreedom = modelDegreesOfFreedom, ...
                HasEffluxContribution = hasEfflux, ...
                MDVRSSContribution = mdvRSS, ...
                EffluxRSSContribution = effluxRSS, ...
                ChiSquareThreshold = ...
                openmebius.application.result.ResultInformationService ...
                .chiSquareThreshold(data));

        end % load

    end % methods

    methods (Static, Access = private)

        function snapshot = snapshotFor(result, batchID)

            snapshot = struct;

            try
                snapshots = result.getBatchSnapshots(batchID);

                if ~isempty(snapshots) && ~isempty(snapshots{1})
                    snapshot = snapshots{1};
                end

            catch
                % Reproducibility metadata is optional for legacy results.
            end

        end % snapshotFor

        function value = snapshotString(snapshot, fieldName, fallback)

            value = string(fallback);

            if isstruct(snapshot) && isfield(snapshot, fieldName) && ...
                    ~isempty(snapshot.(fieldName))
                candidate = string(snapshot.(fieldName));

                if ~isempty(candidate) && strlength(candidate(1)) > 0
                    value = candidate(1);
                end

            end

        end % snapshotString

        function names = snapshotExperiments(snapshot)

            names = strings(0, 1);

            if isstruct(snapshot) && isfield(snapshot, "Experiments")
                names = string(snapshot.Experiments(:));
                names = names(strlength(names) > 0);
            end

        end % snapshotExperiments

        function config = snapshotConfig(snapshot)

            config = [];

            if ~isstruct(snapshot) || ~isfield(snapshot, "ConfigJson") || ...
                    strlength(string(snapshot.ConfigJson)) == 0
                return
            end

            try
                config = jsondecode(char(string(snapshot.ConfigJson)));
            catch
                config = [];
            end

        end % snapshotConfig

        function [differences, available] = differentSettings(config)

            differences = strings(0, 1);
            available = false;

            if isempty(config) || ~isstruct(config) || ~isscalar(config)
                return
            end

            try
                actual = openmebius.domain.batch.BatchIdentity ...
                    .semanticConfig(config);
                defaults = openmebius.domain.batch.BatchIdentity ...
                    .semanticConfig( ...
                    openmebius.domain.batch.BatchConfig.defaultConfig());
                differences = openmebius.application.result ...
                    .ResultInformationService.compareStructs( ...
                    actual, defaults, "");
                available = true;
            catch
                differences = strings(0, 1);
                available = false;
            end

        end % differentSettings

        function differences = compareStructs(actual, defaults, prefix)

            differences = strings(0, 1);
            fields = string(fieldnames(defaults));

            for fieldIndex = 1:numel(fields)
                field = fields(fieldIndex);
                path = field;

                if prefix ~= ""
                    path = prefix + "." + field;
                end

                if ~isfield(actual, field)
                    differences(end + 1, 1) = ...
                        path + ": <missing> (default: " + ...
                        openmebius.application.result ...
                        .ResultInformationService.formatValue( ...
                        defaults.(field)) + ")"; %#ok<AGROW>
                    continue
                end

                actualValue = actual.(field);
                defaultValue = defaults.(field);

                if isstruct(actualValue) && isscalar(actualValue) && ...
                        isstruct(defaultValue) && isscalar(defaultValue)
                    nested = openmebius.application.result ...
                        .ResultInformationService.compareStructs( ...
                        actualValue, defaultValue, path);
                    differences = [differences; nested]; %#ok<AGROW>
                elseif ~openmebius.application.result ...
                        .ResultInformationService.equivalentValues( ...
                        actualValue, defaultValue)
                    differences(end + 1, 1) = ...
                        path + ": " + ...
                        openmebius.application.result ...
                        .ResultInformationService.formatValue(actualValue) + ...
                        " (default: " + ...
                        openmebius.application.result ...
                        .ResultInformationService.formatValue(defaultValue) + ...
                        ")"; %#ok<AGROW>
                end

            end

        end % compareStructs

        function text = formatValue(value)

            if isempty(value)
                text = "[]";
            elseif ischar(value)
                text = "\"" + string(value) + "\"";
            elseif isstring(value)
                quoted = "\"" + value(:) + "\"";

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

        function tf = equivalentValues(actual, defaults)

            if isempty(actual) && isempty(defaults)
                tf = true;
                return
            end

            if (isnumeric(actual) || islogical(actual)) && ...
                    (isnumeric(defaults) || islogical(defaults))
                if isvector(actual) && isvector(defaults)
                    tf = isequaln(double(actual(:)), double(defaults(:)));
                else
                    tf = isequaln(double(actual), double(defaults));
                end

                return
            end

            isActualText = ischar(actual) || isstring(actual) || ...
                iscellstr(actual);
            isDefaultText = ischar(defaults) || isstring(defaults) || ...
                iscellstr(defaults);

            if isActualText && isDefaultText
                tf = isequaln(string(actual(:)), string(defaults(:)));
                return
            end

            tf = isequaln(actual, defaults);

        end % equivalentValues

        function tf = hasEfflux(config)

            tf = false;

            if isstruct(config) && isscalar(config) && ...
                    isfield(config, "perturbateEfflux") && ...
                    ~isempty(config.perturbateEfflux)
                tf = logical(config.perturbateEfflux);
            end

        end % hasEfflux

        function value = effluxDegreesOfFreedom(config)

            value = NaN;

            if ~openmebius.application.result.ResultInformationService ...
                    .hasEfflux(config)
                return
            end

            value = 0;

            if ~isfield(config, "efflux") || ...
                    ~isstruct(config.efflux) || ~isscalar(config.efflux)
                return
            end

            if isfield(config.efflux, "selection")
                value = value + sum(logical(config.efflux.selection(:)));
            end

            if isfield(config.efflux, "muSelection") && ...
                    ~isempty(config.efflux.muSelection)
                value = value + logical(config.efflux.muSelection);
            end

        end % effluxDegreesOfFreedom

        function value = mdvDegreesOfFreedom(data)

            value = NaN;
            required = ["MDVExp", "MDVExpName", "MDVFragMask"];

            if ~isstruct(data) || ...
                    ~all(isfield(data, cellstr(required)))
                return
            end

            experimental = data.MDVExp;
            labels = string(data.MDVExpName);
            mask = logical(data.MDVFragMask);

            if isempty(experimental) || isempty(labels) || isempty(mask)
                return
            end

            rowCount = size(experimental, 1);
            experimentCount = size(experimental, 2);

            if isvector(labels) && isvector(mask) && ...
                    numel(labels) == rowCount && numel(mask) == rowCount
                labels = labels(:);
                mask = mask(:);
                value = experimentCount * ( ...
                    sum(mask) - numel(unique(labels(mask))));
                return
            end

            if ~isequal(size(labels), size(experimental)) || ...
                    ~isequal(size(mask), size(experimental))
                return
            end

            value = 0;

            for experimentIndex = 1:experimentCount
                selected = mask(:, experimentIndex);
                value = value + sum(selected) - ...
                    numel(unique(labels(selected, experimentIndex)));
            end

        end % mdvDegreesOfFreedom

        function value = mdvRSSContribution(data)

            value = NaN;

            if ~isstruct(data) || ~isfield(data, "RSSIdx") || ...
                    isempty(data.RSSIdx) || ~isfield(data, "MDVExp") || ...
                    ~isfield(data, "MDVFragMask")
                return
            end

            field = "fluxResult" + ...
                string(sprintf("%04d", data.RSSIdx(1)));

            if ~isfield(data, field) || ~isfield(data.(field), "MDV")
                return
            end

            experimental = double(data.MDVExp);
            predicted = double(data.(field).MDV);

            if numel(predicted) ~= numel(experimental)
                return
            end

            predicted = reshape(predicted, size(experimental));
            mask = logical(data.MDVFragMask);

            if isvector(mask) && numel(mask) == size(experimental, 1)
                mask = repmat(mask(:), 1, size(experimental, 2));
            end

            if ~isequal(size(mask), size(experimental))
                return
            end

            residual = (predicted(mask) - experimental(mask)) / 0.01;
            value = sum(residual .^ 2, "all");

        end % mdvRSSContribution

        function value = minimumRSS(data)

            value = NaN;

            if isstruct(data) && isfield(data, "RSS") && ...
                    ~isempty(data.RSS)
                value = min(double(data.RSS(:)), [], "omitnan");
            end

        end % minimumRSS

        function value = chiSquareThreshold(data)

            value = NaN;

            if isstruct(data) && isfield(data, "threshold") && ...
                    ~isempty(data.threshold)
                value = double(data.threshold(1));
            end

        end % chiSquareThreshold

        function value = elapsedSeconds(snapshot)

            value = NaN;
            started = openmebius.application.result ...
                .ResultInformationService.snapshotString( ...
                snapshot, "StartedAtUtc", "");
            finished = openmebius.application.result ...
                .ResultInformationService.snapshotString( ...
                snapshot, "FinishedAtUtc", "");

            if started == "" || finished == ""
                return
            end

            try
                startTime = datetime( ...
                    started, ...
                    InputFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX", ...
                    TimeZone = "UTC");
                finishTime = datetime( ...
                    finished, ...
                    InputFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX", ...
                    TimeZone = "UTC");
                value = seconds(finishTime - startTime);
            catch
                value = NaN;
            end

        end % elapsedSeconds

    end % methods (Static, Access = private)

end % classdef
