classdef SlackWebhookNotifier < handle
    % SLACKWEBHOOKNOTIFIER
    % Sends OpenMebius2 notifications to Slack Incoming Webhooks.
    %
    % The webhook URL is stored in OpenMebius2 temporary folder as text.
    % It is not stored in project files and not stored in environment variables.

    properties (Constant)
        TemporaryFolderName = "OpenMebius2"
        WebhookFileName = "slack_webhook.txt"
        EnabledFileName = "slack_notification_enabled.txt"
    end

    properties
        Timeout (1, 1) double = 10
    end

    methods

        function setWebhook(obj, webhookUrl)

            webhookUrl = strtrim(string(webhookUrl));

            if webhookUrl == ""
                obj.clearWebhook();
                return
            end

            obj.validateWebhookUrl(webhookUrl);

            obj.ensureStorageDirectory();

            fid = fopen(obj.webhookFile(), "w");

            if fid < 0
                error( ...
                    "OpenMebius2:Slack:WebhookWriteFailed", ...
                    "Could not open Slack webhook file for writing.");
            end

            cleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>

            fprintf(fid, "%s", webhookUrl);

        end % method setWebhook

        function webhookUrl = getWebhook(obj)

            filePath = obj.webhookFile();

            if ~isfile(filePath)
                webhookUrl = "";
                return
            end

            try
                webhookUrl = strtrim(string(fileread(filePath)));
            catch
                webhookUrl = "";
            end

            if isempty(webhookUrl) || ismissing(webhookUrl)
                webhookUrl = "";
            else
                webhookUrl = webhookUrl(1);
            end

        end % method getWebhook

        function clearWebhook(obj)

            filePath = obj.webhookFile();

            if isfile(filePath)
                delete(filePath);
            end

        end % method clearWebhook

        function setEnabled(obj, enabled)

            arguments
                obj
                enabled (1, 1) logical
            end

            obj.ensureStorageDirectory();

            fid = fopen(obj.enabledFile(), "w");

            if fid < 0
                error( ...
                    "OpenMebius2:Slack:EnabledWriteFailed", ...
                    "Could not open Slack enabled file for writing.");
            end

            cleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>

            fprintf(fid, "%d", enabled);

        end % method setEnabled

        function tf = isEnabled(obj)

            filePath = obj.enabledFile();

            if ~isfile(filePath)
                tf = false;
                return
            end

            try
                value = strtrim(string(fileread(filePath)));
                tf = any(value == ["1", "true", "on", "yes"]);
            catch
                tf = false;
            end

        end % method isEnabled

        function tf = canNotify(obj)

            tf = obj.isEnabled() && obj.getWebhook() ~= "";

        end % method canNotify

        function result = send(obj, message, options)

            arguments
                obj
                message (1, 1) string
                options.Title (1, 1) string = "OpenMebius2"
                options.Status (1, 1) string = "finished"
                options.ProjectName (1, 1) string = ""
                options.BatchStatus (1, 1) string = ""
                options.DeltaTime (1, 1) duration = seconds(0)
            end

            result = struct( ...
                "Success", false, ...
                "Skipped", false, ...
                "Response", "", ...
                "Message", "");

            if ~obj.canNotify()
                result.Skipped = true;
                result.Message = "Slack notification is disabled or webhook is empty.";
                return
            end

            webhookUrl = obj.getWebhook();

            obj.validateWebhookUrl(webhookUrl);

            payload = obj.createPayload( ...
                message, ...
                Title = options.Title, ...
                Status = options.Status, ...
                ProjectName = options.ProjectName, ...
                BatchStatus = options.BatchStatus, ...
                DeltaTime = options.DeltaTime ...
                );

            try
                optionsWeb = weboptions( ...
                    "MediaType", "application/json", ...
                    "Timeout", obj.Timeout);

                response = webwrite(webhookUrl, payload, optionsWeb);

                result.Success = true;
                result.Response = string(response);
                result.Message = "Slack notification sent.";

            catch ME
                result.Success = false;
                result.Message = string(ME.message);
            end

        end % method send

        function masked = maskWebhook(~, webhookUrl)

            webhookUrl = string(webhookUrl);

            if isempty(webhookUrl) || webhookUrl == ""
                masked = "";
                return
            end

            webhookUrl = webhookUrl(1);
            n = strlength(webhookUrl);

            if n <= 16
                masked = join(repmat("*", 1, max(1, n)), "");
                return
            end

            prefix = extractBefore(webhookUrl, 9);
            suffix = extractAfter(webhookUrl, n - 4);

            masked = prefix + "********" + suffix;

        end % method maskWebhook

        function tf = isMaskedWebhook(~, value)

            value = string(value);

            if isempty(value)
                tf = false;
                return
            end

            value = value(1);
            tf = contains(value, "*");

        end % method isMaskedWebhook

        function directory = storageDirectory(~)

            directory = string(fullfile( ...
                tempdir, ...
                openmebius.infrastructure.notification.SlackWebhookNotifier ...
                .TemporaryFolderName));

        end % method storageDirectory

        function filePath = webhookFile(obj)

            filePath = fullfile( ...
                obj.storageDirectory(), ...
                obj.WebhookFileName);

        end % method webhookFile

        function filePath = enabledFile(obj)

            filePath = fullfile( ...
                obj.storageDirectory(), ...
                obj.EnabledFileName);

        end % method enabledFile

    end % methods

    methods (Access = private)

        function ensureStorageDirectory(obj)

            directory = obj.storageDirectory();

            if ~isfolder(directory)
                mkdir(directory);
            end

        end % method ensureStorageDirectory

        function payload = createPayload(~, message, options)

            arguments
                ~
                message (1, 1) string
                options.Title (1, 1) string = "OpenMebius2 Notification"
                options.Status (1, 1) string = "finished"
                options.ProjectName (1, 1) string = ""
                options.BatchStatus (1, 1) string = ""
                options.DeltaTime (1, 1) duration = seconds(0)
            end

            title = options.Title;

            nowText = "*Time:*" + newline + string(options.DeltaTime);
            system = System();
            osinfo = system.getOperatingSystem();
            cpuInfo = system.getCPUInfo();
            ramInfo = system.getRAMInfo();
            osText = "*OS:*" + newline + osinfo;
            cpuText = "*CPU:*" + newline + cpuInfo;
            ramText = "*RAM:*" + newline + ramInfo;
            statusText = "*Status:*" + newline + options.Status;
            batchText = "*Batch:*" + newline + options.BatchStatus;
            projectText = "*Project:*" + newline + options.ProjectName;

            payload = struct( ...
                "attachments", {{
                struct( ...
                "color", "#36a64f", ...
                "blocks", {{ ...
                struct( ...
                "type", "section", ...
                "text", struct( ...
                "type", "mrkdwn", ...
                "text", message ...
                ) ...
                ), ...
                struct( ...
                "type", "section", ...
                "fields", {{ ...
                struct( ...
                "type", "mrkdwn", ...
                "text", projectText ...
                ), ...
                struct( ...
                "type", "mrkdwn", ...
                "text", "*Type:*" + newline + "Computer (laptop)" ...
                ), ...
                struct( ...
                "type", "mrkdwn", ...
                "text", nowText ...
                ), ...
                struct( ...
                "type", "mrkdwn", ...
                "text", osText ...
                ), ...
                struct( ...
                "type", "mrkdwn", ...
                "text", cpuText ...
                ), ...
                struct( ...
                "type", "mrkdwn", ...
                "text", ramText ...
                ), ...
                struct( ...
                "type", "mrkdwn", ...
                "text", statusText ...
                ), ...
                struct( ...
                "type", "mrkdwn", ...
                "text", batchText ...
                ) ...
                }} ...
                ) ...
                }} ...
                )}});

            payload.text = title + " - " + message;

        end % method createPayload

    end % methods (Access = private)

    methods (Static)

        function validateWebhookUrl(webhookUrl)

            webhookUrl = strtrim(string(webhookUrl));

            allowedPrefixes = [
                "https://hooks.slack.com/services/"
                "https://hooks.slack-gov.com/services/"
                ];

            if ~any(startsWith(webhookUrl, allowedPrefixes))
                error( ...
                    "OpenMebius2:Slack:InvalidWebhookUrl", ...
                    "Slack webhook URL must start with https://hooks.slack.com/services/ or https://hooks.slack-gov.com/services/.");
            end

        end % method validateWebhookUrl

    end % methods (Static)

end % classdef
