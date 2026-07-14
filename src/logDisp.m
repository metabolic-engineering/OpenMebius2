function msg = logDisp(dbstackObj, text, level, loglevel)
    % LOGDISP Display log messages with different severity levels.
    %
    % msg = logDisp(text, level)
    %
    % Paramters:
    % ----------
    % text : (1 x 1) string
    %     The log message to be displayed.
    % level : (1 x 1) string
    %     The severity level of the log message. Can be 'info', 'warning', or 'error'.

    arguments
        dbstackObj
        text (1, 1) string
        level (1, 1) string = "info"
        loglevel (1, 1) string = "debug"
    end

    if isempty(dbstackObj)
        dbs = "unknown";
    else
        dbs = dbstackObj(1).name;
    end

    msg = openmebius.infrastructure.logging.Logger ...
        .formatDatedMessage(dbs + ": " + text, level);

    if ~openmebius.infrastructure.logging.Logger ...
            .shouldLog(level, loglevel)
        return;
    end

    openmebius.infrastructure.logging.Logger.writeText(msg);

end % logDisp
