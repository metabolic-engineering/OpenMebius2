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
        level (1, 1) string {mustBeMember(level, ["fatal", "error", "warning", "info", "debug"])} = "info"
        loglevel (1, 1) string {mustBeMember(loglevel, ["fatal", "error", "warning", "info", "debug"])} = "debug"
    end

    timestamp = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');

    levels = ["fatal", "error", "warning", "info", "debug"];
    prefix = ["[FATAL]", "[ERROR]", "[WARNING]", "[INFO]", "[DEBUG]"];
    levelIdx = find(levels == level);

    if isempty(dbstackObj)
        dbs = "unknown";
    else
        dbs = dbstackObj(1).name;
    end

    msg = string(timestamp) + char(9) + prefix(levelIdx) + char(9) + dbs +char(9) + text;

    if find(levels == loglevel) < levelIdx
        return;
    end

    disp(msg);

end % logDisp
