classdef SlackWebhookNotifierStub < ...
        openmebius.infrastructure.notification.SlackWebhookNotifier
    % SLACKWEBHOOKNOTIFIERSTUB Avoids filesystem writes in UI tests.

    properties
        Enabled (1, 1) logical = false
        Webhook (1, 1) string = ""
    end

    methods

        function setEnabled(obj, enabled)

            obj.Enabled = logical(enabled);

        end

        function enabled = isEnabled(obj)

            enabled = obj.Enabled;

        end

        function setWebhook(obj, webhook)

            obj.Webhook = string(webhook);

        end

        function webhook = getWebhook(obj)

            webhook = obj.Webhook;

        end

        function clearWebhook(obj)

            obj.Webhook = "";

        end

    end

end % classdef
