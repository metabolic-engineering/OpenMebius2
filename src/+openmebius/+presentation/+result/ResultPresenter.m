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
            rawData = tableData;
            tableData.ID = openmebius.presentation ...
                .IdentifierFormatter.short(tableData.ID);

            styleRules = obj.chi2StyleRules(isPassed);

            viewModel = ...
                openmebius.presentation.result.ResultTableViewModel( ...
                Data = tableData, ...
                RawData = rawData, ...
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

                case "MDV"
                    viewModel = obj.presentMDV( ...
                        result, ...
                        batchIDs(1), ...
                        IsDarkTheme = options.IsDarkTheme);

                case "MDV (Summary)"
                    viewModel = obj.presentMDVSummary( ...
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

            if outcome.isSuccess()
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

            if outcome.isSuccess()
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

        function viewModel = presentSuggestionOutcome(obj, outcome)

            arguments
                obj
                outcome (1, 1) openmebius.application.result ...
                    .ResultOperationOutcome
            end

            if outcome.isSuccess()
                viewModel = openmebius.presentation.result ...
                    .ResultOperationViewModel( ...
                    Suggestion = outcome.Result.Suggestion);
                return
            end

            identifier = obj.outcomeIdentifier(outcome);
            message = obj.outcomeMessage( ...
                outcome, "Failed to load labeling suggestion.");
            knownIdentifiers = [ ...
                "OpenMebius2:ResultSuggestion:SelectionRequired"
                "OpenMebius2:ResultSuggestion:NotAvailable"
                "OpenMebius2:ResultSuggestion:ResultUnavailable"];

            if any(identifier == knownIdentifiers)
                notification = openmebius.presentation.notification ...
                    .Notification.warning(message);
            else
                notification = openmebius.presentation.notification ...
                    .Notification.error( ...
                    message, ...
                    Title = "Suggestion load failed", ...
                    ShowAlert = true);
            end

            viewModel = openmebius.presentation.result ...
                .ResultOperationViewModel( ...
                Notifications = {notification});

        end % presentSuggestionOutcome

        function viewModel = presentRelativeSelection( ...
                ~, rowNames, selectedRows)

            arguments
                ~
                rowNames
                selectedRows (:, 1) double
            end

            if isempty(selectedRows)
                viewModel = openmebius.presentation.result ...
                    .ResultRelativeViewModel( ...
                    Notifications = { ...
                    openmebius.presentation.notification ...
                    .Notification.warning( ...
                    "Please select a flux to set " + ...
                    "relative values.")});
                return
            end

            rowNames = string(rowNames);
            rowNames = rowNames(:);
            selectedRow = selectedRows(1);

            if isempty(rowNames) || ...
                    selectedRow < 1 || ...
                    selectedRow > numel(rowNames) || ...
                    selectedRow ~= fix(selectedRow) || ...
                    strlength(rowNames(selectedRow)) == 0
                viewModel = openmebius.presentation.result ...
                    .ResultRelativeViewModel( ...
                    Notifications = { ...
                    openmebius.presentation.notification ...
                    .Notification.warning( ...
                    "Reaction identifiers are not available " + ...
                    "for relative values.")});
                return
            end

            viewModel = openmebius.presentation.result ...
                .ResultRelativeViewModel( ...
                RelativeTo = rowNames(selectedRow));

        end % presentRelativeSelection

        function viewModel = presentRangePlotOutcome(obj, outcome)

            arguments
                obj
                outcome (1, 1) openmebius.application.result ...
                    .ResultOperationOutcome
            end

            if outcome.isSuccess()
                result = outcome.Result;
                messages = string(result.Messages);
                messages = messages(:);
                notifications = cell(numel(messages), 1);

                for messageIndex = 1:numel(messages)
                    notifications{messageIndex} = ...
                        openmebius.presentation.notification ...
                        .Notification.info(messages(messageIndex));
                end

                viewModel = openmebius.presentation.result ...
                    .ResultRangePlotViewModel( ...
                    UpperBounds = result.UpperBounds, ...
                    LowerBounds = result.LowerBounds, ...
                    BestFits = result.BestFits, ...
                    ReactionNames = result.ReactionNames, ...
                    Notifications = notifications);
                return
            end

            identifier = obj.outcomeIdentifier(outcome);
            message = obj.outcomeMessage( ...
                outcome, "Failed to prepare the range plot.");
            warningIdentifiers = [ ...
                "OpenMebius2:ResultRangePlot:SelectionRequired"
                "OpenMebius2:ResultRangePlot:SelectionMismatch"
                "OpenMebius2:ResultRangePlot:DuplicateSelection"
                "OpenMebius2:ResultRangePlot:ResultUnavailable"
                "OpenMebius2:ResultRangePlot:DataUnavailable"];
            knownErrorIdentifiers = [ ...
                "OpenMebius2:ResultRangePlot:ReactionMismatch"
                "OpenMebius2:ResultRangePlot:InvalidBounds"
                "OpenMebius2:ResultRangePlot:InvalidData"];

            if any(identifier == warningIdentifiers)
                notification = openmebius.presentation.notification ...
                    .Notification.warning(message);
            else
                notification = openmebius.presentation.notification ...
                    .Notification.error( ...
                    message, ...
                    Title = "Range plot failed", ...
                    ShowAlert = ...
                    ~any(identifier == knownErrorIdentifiers));
            end

            viewModel = openmebius.presentation.result ...
                .ResultRangePlotViewModel( ...
                Notifications = {notification});

        end % presentRangePlotOutcome

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

        function viewModel = presentMDV(obj, result, batchID, options)

            arguments
                obj
                result
                batchID (1, 1) string
                options.IsDarkTheme (1, 1) logical = false
            end

            raw = getMDV(result, batchID);

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

        function viewModel = presentMDVSummary(obj, result, batchID, options)

            arguments
                obj
                result
                batchID (1, 1) string
                options.IsDarkTheme (1, 1) logical = false
            end

            raw = getMDVSummary(result, batchID);
            formatted = obj.formatDisplayColumn(raw, 2, 100, "%.0f%%");
            formatted = obj.formatDisplayColumn(formatted, 3, 1, "%.3f");
            formatted = obj.formatDisplayColumn(formatted, 4, 1, "%.2f");
            styleRules = [
                obj.columnStyleRules(2:width(raw), "align-right")
                obj.heatmapRules( ...
                raw, ...
                4, ...
                IsDarkTheme = options.IsDarkTheme)
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

        function formatted = formatDisplayColumn( ...
                ~, tableData, column, scale, formatSpec)

            formatted = tableData;

            if isempty(tableData) || column > width(tableData)
                return
            end

            values = tableData{:, column};

            if ~isnumeric(values)
                return
            end

            variableName = tableData.Properties.VariableNames{column};
            formatted.(variableName) = compose( ...
                formatSpec, values .* scale);

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

        function styleRules = detailHeatmapRules(obj, tableData, options)

            arguments
                obj
                tableData table
                options.IsDarkTheme (1, 1) logical = false
            end

            styleRules = obj.heatmapRules( ...
                tableData, ...
                5:3:width(tableData), ...
                IsDarkTheme = options.IsDarkTheme);

        end % method detailHeatmapRules

        function styleRules = heatmapRules(~, tableData, columns, options)

            arguments
                ~
                tableData table
                columns (1, :) double
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

            for c = columns

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

        end % method heatmapRules

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
