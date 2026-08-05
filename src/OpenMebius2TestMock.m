classdef OpenMebius2TestMock < OpenMebius2

    properties
        Test_InputAnswer string = "NewProject"
        Test_InputOK (1, 1) logical = true

        Test_Folder string = string(tempdir)
        Test_GetDirOK (1, 1) logical = true

        Test_File string = fullfile(string(tempdir), "dummy.txt")
        Test_Files string = [
                             fullfile(string(tempdir), "a.txt")
                             fullfile(string(tempdir), "b.txt")
                             ]
        Test_GetFileOK (1, 1) logical = true

        Test_ConfirmAnswer (1, 1) string = "Yes"
        Test_ConfirmOK (1, 1) logical = true

        Test_TriggerCancelDuringRun (1, 1) logical = false
        Test_RunInvoked (1, 1) logical = false
        Test_CancelInvoked (1, 1) logical = false
        Test_ReportCreated (1, 1) logical = false
        Test_ReportViewed (1, 1) logical = false
        Test_ReportOutput (1, 1) string = ""
        Test_Alerts (:, 1) string = strings(0, 1)
        Test_ApplicationController
    end

    methods

        function tf = testHasCalculatedMDV(app)

            tf = app.Test_ApplicationController ...
                .experiments().hasCalculatedMDV();

        end

    end

    methods (Access = protected)

        function dependencies = createMainAppDependencies(app)

            batchRunController = openmebius.application.batch ...
                .BatchRunController( ...
                Runner = @(batch, directory, reporters) ...
                app.executeSmokeBatch( ...
                batch, directory, reporters), ...
                Canceler = @(batch) app.cancelSmokeBatch(batch));
            reportRepository = struct( ...
                "create", @(location, model, experiments, result) ...
                app.createSmokeReport( ...
                location, model, experiments, result), ...
                "view", @(report) app.viewSmokeReport(report), ...
                "outputPath", @(report, location) ...
                app.writeSmokeReport(report, location));
            reportService = openmebius.application.report ...
                .ReportGenerationService( ...
                ReportRepository = reportRepository);
            resultController = openmebius.application.result ...
                .ResultOperationController( ...
                ReportGenerationService = reportService);
            dependencies = openmebius.bootstrap ...
                .MainAppCompositionRoot.create( ...
                BatchRunController = batchRunController, ...
                ResultController = resultController);
            app.Test_ApplicationController = ...
                dependencies.ApplicationController;

        end

        function performStartupUpdateCheck(~)
        end

        function [folder, isOK] = uiGetDirWrap(app, varargin)
            %#ok<*INUSD>
            if app.Test_GetDirOK
                folder = app.Test_Folder;
                isOK = true;
            else
                folder = "";
                isOK = false;
            end

        end

        function [answer, isOK] = uiInputDlgWrap(app, varargin)
            % Name-Value 呼び出しを吸収するために varargin を受ける

            % 本体互換：Prompt の数だけ返す（複数入力にも対応）
            n = 1;

            if ~isempty(varargin)

                try
                    opt = struct(varargin{:}); % Prompt=... を拾う

                    if isfield(opt, "Prompt")
                        n = numel(opt.Prompt);
                        if n == 0, n = 1; end
                    end

                catch
                    n = 1; % 変でも落とさない（テスト優先）
                end

            end

            if app.Test_InputOK
                answer = repmat(string(app.Test_InputAnswer), n, 1);
                isOK = true;
            else
                answer = strings(n, 1);
                isOK = false;
            end

        end

        function [files, isOK] = uiGetFileWrap(app, varargin)

            multi = "off";

            if ~isempty(varargin)

                try
                    opt = struct(varargin{:});

                    if isfield(opt, "MultiSelect")
                        multi = string(opt.MultiSelect);
                    end

                catch
                    multi = "off";
                end

            end

            if app.Test_GetFileOK
                isOK = true;

                if multi == "on"
                    files = string(app.Test_Files(:));
                else
                    files = string(app.Test_File);
                end

            else
                isOK = false;

                if multi == "on"
                    files = string.empty(0, 1);
                else
                    files = "";
                end

            end

        end

        function uiAlertWrap(app, message, varargin)

            app.Test_Alerts(end + 1, 1) = string(message);

        end

        function [answer, isOK] = uiConfirmWrap(app, varargin)

            answer = app.Test_ConfirmAnswer;
            isOK = app.Test_ConfirmOK;

        end

        function result = executeSmokeBatch( ...
                app, ~, ~, ~)

            app.Test_RunInvoked = true;

            if app.Test_TriggerCancelDuringRun
                callback = app.RunRunButton.ButtonPushedFcn;
                callback(app.RunRunButton, []);
            end

            result = openmebius.application.batch ...
                .BatchExecutionResult( ...
                ~app.Test_CancelInvoked, ...
                Canceled = app.Test_CancelInvoked);

        end

        function cancelSmokeBatch(app, ~)

            app.Test_CancelInvoked = true;

        end

        function report = createSmokeReport(app, varargin)

            app.Test_ReportCreated = true;
            report = struct("Type", "UI smoke report");

        end

        function viewSmokeReport(app, ~)

            app.Test_ReportViewed = true;

        end

        function path = writeSmokeReport(app, ~, location)

            path = location.summaryReportFile();
            fid = fopen(path, "w");

            if fid < 0
                error( ...
                    "OpenMebius2:Test:ReportWriteFailed", ...
                    "Could not create UI smoke report: %s", path);
            end

            cleanup = onCleanup(@() fclose(fid));
            fprintf(fid, "<html><body>OpenMebius2 smoke report</body></html>");
            clear cleanup
            app.Test_ReportOutput = path;

        end

    end

end
