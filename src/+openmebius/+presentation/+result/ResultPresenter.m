classdef ResultPresenter < handle

    methods

        function viewModel = presentIndex(obj, result, batch)

            obj.mustBeValidHandle(result, "Result");
            obj.mustBeValidHandle(batch, "Batch");

            batchGUI = getBatchForGUI(batch);
            batchIDs = string(batchGUI.ID);
            batchStatus = getBatchStatus(batch, batchIDs);

            finishedMask = batchStatus == "finished";
            finishedBatchGUI = batchGUI(finishedMask, :);
            finishedBatchIDs = batchIDs(finishedMask);

            [data, dataMask] = loadResultFiles(result, finishedBatchIDs);

            if isempty(data(dataMask))
                viewModel = ...
                    openmebius.presentation.result.ResultTableViewModel( ...
                    Data = table(), ...
                    ColumnEditable = false(1, 0));
                return
            end

            data = data(dataMask);
            batchIDs = finishedBatchIDs(dataMask);
            batchNames = string(finishedBatchGUI.Name(dataMask));

            rss = getRSS(result, data);
            isPassed = getIsPassedChi2Test(result, data);

            tableData = table( ...
                batchIDs(:), ...
                batchNames(:), ...
                rss(:), ...
                'VariableNames', ["ID", "Name", "RSS"]);

            styleRules = obj.chi2StyleRules(isPassed);

            viewModel = ...
                openmebius.presentation.result.ResultTableViewModel( ...
                Data = tableData, ...
                ColumnEditable = false(1, width(tableData)), ...
                StyleRules = styleRules);

        end

        function viewModel = presentMain(obj, result, mode, batchIDs, names, options)

            arguments
                obj
                result
                mode
                batchIDs string
                names string = strings(0, 1)
                options.Relative (1, 1) logical = false
                options.RelativeTo (1, 1) string = ""
                options.IsDarkTheme (1, 1) logical = false
            end

            obj.mustBeValidHandle(result, "Result");

            mode = ...
                openmebius.presentation.result.ResultViewMode.normalize(mode);

            switch mode

                case "Overview"
                    viewModel = obj.presentOverview( ...
                        result, ...
                        batchIDs(1), ...
                        Relative = options.Relative, ...
                        RelativeTo = options.RelativeTo);

                case "Details"
                    viewModel = obj.presentDetails( ...
                        result, ...
                        batchIDs(1), ...
                        IsDarkTheme = options.IsDarkTheme);

                case "Comparison"
                    viewModel = obj.presentComparison( ...
                        result, ...
                        batchIDs, ...
                        names, ...
                        Relative = options.Relative, ...
                        RelativeTo = options.RelativeTo);

                otherwise
                    error( ...
                        "OpenMebius2:Result:InvalidViewMode", ...
                    "Unknown result view mode.");
            end

        end

        function viewModel = presentReportOutcome(obj, outcome)

            arguments
                obj
                outcome (1, 1) openmebius.application.result ...
                    .ResultOperationOutcome
            end

            report = [];

            if outcome.Status == "finished"
                report = outcome.Result.Report;
                notifications = obj.operationNotifications( ...
                    outcome.Result, "Report generated successfully.");
            else
                identifier = obj.outcomeIdentifier(outcome);

                switch identifier
                    case "OpenMebius2:Report:UnavailableInDeployed"
                        notification = ...
                            openmebius.presentation.notification ...
                            .Notification.warning( ...
                                obj.outcomeMessage( ...
                                    outcome, ...
                                    "Report generation is unavailable."));

                    case "OpenMebius2:Report:DataUnavailable"
                        notification = ...
                            openmebius.presentation.notification ...
                            .Notification.error( ...
                                obj.outcomeMessage( ...
                                    outcome, ...
                                    "Report data is unavailable."));

                    otherwise
                        notification = ...
                            openmebius.presentation.notification ...
                            .Notification.error( ...
                                obj.outcomeMessage( ...
                                    outcome, ...
                                    "Report generation failed."), ...
                                Title = "Report generation failed", ...
                                ShowAlert = true);
                end

                notifications = {notification};
            end

            viewModel = openmebius.presentation.result ...
                .ResultOperationViewModel( ...
                    Report = report, ...
                    Notifications = notifications);

        end % presentReportOutcome

        function viewModel = presentExportOutcome(obj, outcome)

            arguments
                obj
                outcome (1, 1) openmebius.application.result ...
                    .ResultOperationOutcome
            end

            if outcome.Status == "finished"
                notifications = obj.operationNotifications( ...
                    outcome.Result, ...
                    "Result export completed successfully.");
            else
                identifier = obj.outcomeIdentifier(outcome);
                knownIdentifiers = [ ...
                    "OpenMebius2:ResultExport:ResultUnavailable"
                    "OpenMebius2:ResultExport:EmptySelection"
                    "OpenMebius2:ResultExport:SelectionMismatch"
                    "OpenMebius2:ResultExport:OutputDirectoryUnavailable"
                    "OpenMebius2:ResultExport:OutputDirectoryNotFound"
                    "OpenMebius2:ResultExport:OutputDirectoryExists"
                    "OpenMebius2:ResultExport:CreateDirectoryFailed"];
                isKnownError = any(identifier == knownIdentifiers);
                notification = ...
                    openmebius.presentation.notification ...
                    .Notification.error( ...
                        obj.outcomeMessage( ...
                            outcome, "Result export failed."), ...
                        Title = "Result export failed", ...
                        ShowAlert = ~isKnownError);
                notifications = {notification};
            end

            viewModel = openmebius.presentation.result ...
                .ResultOperationViewModel( ...
                    Notifications = notifications);

        end % presentExportOutcome

        function viewModel = presentReloaded(~)

            notification = openmebius.presentation.notification ...
                .Notification.info("Result data reloaded");
            viewModel = openmebius.presentation.result ...
                .ResultOperationViewModel( ...
                    Notifications = {notification});

        end % presentReloaded

        function viewModel = presentExportSelectionRequired(~)

            notification = openmebius.presentation.notification ...
                .Notification.warning( ...
                    "Please select a result to save.");
            viewModel = openmebius.presentation.result ...
                .ResultOperationViewModel( ...
                    Notifications = {notification});

        end % presentExportSelectionRequired

    end

    methods (Access = private)

        function viewModel = presentOverview(obj, result, batchID, options)

            arguments
                obj
                result
                batchID (1, 1) string
                options.Relative (1, 1) logical = false
                options.RelativeTo (1, 1) string = ""
            end

            if ~options.Relative
                tableData = getFluxOverView(result, batchID);
            else
                tableData = getFluxOverView( ...
                    result, ...
                    batchID, ...
                    relative = options.Relative, ...
                    relativeTo = options.RelativeTo);
            end

            formatted = obj.formatNumericColumns(tableData, 2:width(tableData), "%.2f");

            styleRules = obj.columnStyleRules( ...
                2:width(tableData), ...
            "align-right");

            viewModel = ...
                openmebius.presentation.result.ResultTableViewModel( ...
                Data = formatted, ...
                RawData = tableData, ...
                ColumnEditable = false(1, width(formatted)), ...
                StyleRules = styleRules);
        end

        function viewModel = presentDetails(obj, result, batchID, options)

            arguments
                obj
                result
                batchID (1, 1) string
                options.IsDarkTheme (1, 1) logical = false
            end

            raw = getFluxDetailed(result, batchID);

            formatted = obj.formatNumericColumns(raw, 3:width(raw), "%.4f");

            styleRules = [
                          obj.columnStyleRules(3:width(raw), "align-right")
                          obj.detailHeatmapRules(raw, IsDarkTheme = options.IsDarkTheme)
                          ];

            viewModel = ...
                openmebius.presentation.result.ResultTableViewModel( ...
                Data = formatted, ...
                RawData = raw, ...
                ColumnEditable = false(1, width(formatted)), ...
                StyleRules = styleRules);

        end

        function viewModel = presentComparison(obj, result, batchIDs, names, options)

            arguments
                obj
                result
                batchIDs string
                names string
                options.Relative (1, 1) logical = false
                options.RelativeTo (1, 1) string = ""
            end

            tableData = getFluxComparison( ...
                result, ...
                batchIDs, ...
                names, ...
                relative = options.Relative, ...
                relativeTo = options.RelativeTo);

            if isempty(tableData)
                viewModel = ...
                    openmebius.presentation.result.ResultTableViewModel( ...
                    Data = table(), ...
                    ColumnEditable = false(1, 0));
                return
            end

            formatted = obj.formatNumericColumns(tableData, 2:width(tableData), "%.2f");

            styleRules = obj.columnStyleRules( ...
                2:width(tableData), ...
            "align-right");

            viewModel = ...
                openmebius.presentation.result.ResultTableViewModel( ...
                Data = formatted, ...
                RawData = tableData, ...
                ColumnEditable = false(1, width(formatted)), ...
                StyleRules = styleRules);

        end

        function formatted = formatNumericColumns(~, tableData, columns, formatSpec)

            formatted = tableData;

            if isempty(tableData)
                return
            end

            for c = columns

                values = tableData{:, c};

                if ~isnumeric(values)
                    continue
                end

                formattedValues = arrayfun( ...
                    @(x) sprintf(formatSpec, x), ...
                    values, ...
                    'UniformOutput', false);

                formatted{:, c} = string(formattedValues);

            end

        end

        function styleRules = chi2StyleRules(~, isPassed)

            isPassed = logical(isPassed(:));

            styleRules = struct( ...
                "Target", {}, ...
                "Rows", {}, ...
                "Columns", {}, ...
                "StyleKey", {}, ...
                "Value", {});

            for i = 1:numel(isPassed)

                if isPassed(i)
                    key = "chi2-passed";
                else
                    key = "chi2-failed";
                end

                styleRules(end + 1, 1) = struct( ...
                    "Target", "cell", ...
                    "Rows", i, ...
                    "Columns", 3, ...
                    "StyleKey", key, ...
                    "Value", ""); %#ok<AGROW>

            end

        end

        function styleRules = columnStyleRules(~, columns, styleKey)

            columns = columns(:)';

            styleRules = struct( ...
                "Target", {}, ...
                "Rows", {}, ...
                "Columns", {}, ...
                "StyleKey", {}, ...
                "Value", {});

            for i = 1:numel(columns)

                styleRules(end + 1, 1) = struct( ...
                    "Target", "column", ...
                    "Rows", [], ...
                    "Columns", columns(i), ...
                    "StyleKey", styleKey, ...
                    "Value", ""); %#ok<AGROW>

            end

        end

        function styleRules = detailHeatmapRules(~, tableData, options)

            arguments
                ~
                tableData table
                options.IsDarkTheme (1, 1) logical = false
            end

            styleRules = struct( ...
                "Target", {}, ...
                "Rows", {}, ...
                "Columns", {}, ...
                "StyleKey", {}, ...
                "Value", {});

            if isempty(tableData)
                return
            end

            color = Color();

            for c = 3:width(tableData)

                if mod(c, 3) ~= 2
                    continue
                end

                values = tableData{:, c};

                if ~isnumeric(values)
                    continue
                end

                minValue = min(values, [], "omitnan");
                maxValue = max(values, [], "omitnan");

                if maxValue == minValue
                    normalized = zeros(size(values));
                else
                    normalized = 0.99 * ...
                        (values - minValue) ./ (maxValue - minValue);
                end

                hex = getColorValue( ...
                    color, ...
                    normalized, ...
                    "color", "cmthermallight", ...
                    "isDark", options.IsDarkTheme);

                for r = 1:numel(values)

                    styleRules(end + 1, 1) = struct( ...
                        "Target", "cell", ...
                        "Rows", r, ...
                        "Columns", c, ...
                        "StyleKey", "background", ...
                        "Value", string(hex(r, :))); %#ok<AGROW>

                end

            end

        end % method detailHeatmapRules

        function mustBeValidHandle(~, value, name)

            if isempty(value)
                error( ...
                    "OpenMebius2:Result:InvalidObject", ...
                    "%s object is empty.", name);
            end

            try

                if ~isvalid(value)
                    error( ...
                        "OpenMebius2:Result:InvalidObject", ...
                        "%s object is invalid.", name);
                end

            catch ME

                if ME.identifier == "OpenMebius2:Result:InvalidObject"
                    rethrow(ME)
                end

            end

        end % method mustBeValidHandle

        function notifications = operationNotifications( ...
                ~, result, fallbackMessage)

            messages = string(result.Messages);
            messages = messages(:);

            if isempty(messages)
                messages = fallbackMessage;
            end

            notifications = cell(numel(messages), 1);

            for messageIndex = 1:numel(messages)
                notifications{messageIndex} = ...
                    openmebius.presentation.notification ...
                    .Notification.info(messages(messageIndex));
            end

        end % operationNotifications

        function identifier = outcomeIdentifier(~, outcome)

            identifier = "";

            if ~isempty(outcome.Exception)
                identifier = string(outcome.Exception.identifier);
            end

        end % outcomeIdentifier

        function message = outcomeMessage(~, outcome, fallbackMessage)

            message = outcome.ErrorMessage;

            if message == ""
                message = fallbackMessage;
            end

        end % outcomeMessage

    end

end % classdef
