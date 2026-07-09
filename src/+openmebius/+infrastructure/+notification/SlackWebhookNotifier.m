classdef SlackWebhookNotifier < handle
    % SLACKWEBHOOKNOTIFIER
    % Sends OpenMebius2 notifications to Slack Incoming Webhooks.
    %
    % The webhook URL is treated as a secret. It is read from / written to
    % the MATLAB process environment variable OM2_SLACK_WEBHOOK.

    properties (Constant)
        EnvironmentVariableName = "OM2_SLACK_WEBHOOK"
    end

    properties
        Timeout (1, 1) double = 10
    end

    methods

        function setWebhook(~, webhookUrl)

            webhookUrl = strtrim(string(webhookUrl));

            if webhookUrl == ""
                setenv( ...
                    openmebius.infrastructure.notification.SlackWebhookNotifier ...
                    .EnvironmentVariableName, ...
                "");
                return
            end

            openmebius.infrastructure.notification.SlackWebhookNotifier ...
                .validateWebhookUrl(webhookUrl);

            setenv( ...
                openmebius.infrastructure.notification.SlackWebhookNotifier ...
                .EnvironmentVariableName, ...
                char(webhookUrl));

        end % method setWebhook

        function webhookUrl = getWebhook(~)

            webhookUrl = string(getenv( ...
                openmebius.infrastructure.notification.SlackWebhookNotifier ...
                .EnvironmentVariableName));

            if isempty(webhookUrl)
                webhookUrl = "";
            else
                webhookUrl = strtrim(webhookUrl(1));
            end

        end % method getWebhook

        function tf = hasWebhook(obj)

            tf = obj.getWebhook() ~= "";

        end % method hasWebhook

        function result = send(obj, message, options)

            arguments
                obj
                message (1, 1) string
                options.Title (1, 1) string = "OpenMebius2"
                options.Status (1, 1) string = "finished"
                options.ProjectName (1, 1) string = ""
                options.BatchStatus (1, 1) string = ""
            end

            webhookUrl = obj.getWebhook();

            result = struct( ...
                "Success", false, ...
                "Skipped", false, ...
                "Response", "", ...
                "Message", "");

            if webhookUrl == ""
                result.Skipped = true;
                result.Message = "Slack webhook is not configured.";
                return
            end

            openmebius.infrastructure.notification.SlackWebhookNotifier ...
                .validateWebhookUrl(webhookUrl);

            payload = obj.createPayload( ...
                message, ...
                Title = options.Title, ...
                Status = options.Status, ...
                ProjectName = options.ProjectName, ...
                BatchStatus = options.BatchStatus);

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

            if webhookUrl == ""
                masked = "";
                return
            end

            n = strlength(webhookUrl);

            if n <= 12
                masked = join(repmat("*", 1, max(1, n)), "");
                return
            end

            prefix = extractBefore(webhookUrl, min(9, n));
            suffix = extractAfter(webhookUrl, max(n - 4, 1));

            masked = prefix + "********" + suffix;

        end % method maskWebhook

    end % methods

    methods (Access = private)

        function payload = createPayload(~, message, options)

            arguments
                ~
                message (1, 1) string
                options.Title (1, 1) string = "OpenMebius2"
                options.Status (1, 1) string = "finished"
                options.ProjectName (1, 1) string = ""
                options.BatchStatus (1, 1) string = ""
            end

            title = options.Title;

            if options.ProjectName ~= ""
                title = title + " - " + options.ProjectName;
            end

            fields = strings(0, 1);
            fields(end + 1, 1) = "*Status:* " + options.Status;

            if options.BatchStatus ~= ""
                fields(end + 1, 1) = "*Batch:* " + options.BatchStatus;
            end

            fields(end + 1, 1) = ...
                "*Time:* " + string(datetime( ...
                "now", ...
                "Format", ...
            "yyyy-MM-dd HH:mm:ss"));

            payload = struct();

            payload.text = char("*" + title + "*\n" + message);

            payload.blocks = { ...
                                  struct( ...
                                  "type", "section", ...
                                  "text", struct( ...
                                  "type", "mrkdwn", ...
                                  "text", char("*" + title + "*\n" + message))), ...
                                  struct( ...
                                  "type", "section", ...
                                  "text", struct( ...
                                  "type", "mrkdwn", ...
                                  "text", char(join(fields, "\n")))) ...
                              };

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
