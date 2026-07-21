function synchronizeMlappSource(appNames, root)
%SYNCHRONIZEMLAPPSOURCE Replace both mlapp code stores from exports.

arguments
    appNames (:, 1) string = strings(0, 1)
    root (1, 1) string = string(fileparts(fileparts(mfilename("fullpath"))))
end

if isempty(appNames)
    appFiles = dir(fullfile(root, "src", "*.mlapp"));
    appNames = sort(erase(string({appFiles.name}).', ".mlapp"));
end

for appIndex = 1:numel(appNames)
    appName = appNames(appIndex);
    exportedPath = fullfile( ...
        root, "src", appName + "_exported.m");
    mlappPath = fullfile(root, "src", appName + ".mlapp");

    if ~isfile(exportedPath) || ~isfile(mlappPath)
        error( ...
            "OpenMebius2:Development:MissingAppSource", ...
            "Both exported source and mlapp are required for %s.", ...
            appName);
    end

    source = string(fileread(exportedPath));
    source = replace(source, appName + "_exported", appName);
    synchronizeCodeStores(mlappPath, source);
end

end

function synchronizeCodeStores(mlappPath, source)

mlappPath = char(mlappPath);
[currentCode, ~, metadata] = ...
    appdesigner.internal.comparison.getAppData(mlappPath);
parser = appdesigner.internal.serialization.PlainTextCodeParser(source);
callbackInfo = struct( ...
    AssignedCallbacks = currentCode.Callbacks, ...
    Children = struct.empty);
startupName = "";

if isfield(currentCode, 'StartupCallback') && ...
        ~isempty(currentCode.StartupCallback)
    startupName = string(currentCode.StartupCallback.Name);
end

isSingleton = isfield(currentCode, 'SingletonMode') && ...
    strcmp(currentCode.SingletonMode, 'FOCUS');
updatedCode = parser.parseCodeData( ...
    callbackInfo, startupName, isSingleton, string(metadata.AppType));

if isfield(updatedCode, 'StartupFcn')
    updatedCode.StartupCallback = updatedCode.StartupFcn;
    updatedCode = rmfield(updatedCode, 'StartupFcn');
end

fieldsToUpdate = [ ...
    "ClassName", ...
    "EditableSectionCode", ...
    "Callbacks", ...
    "StartupCallback", ...
    "InputParameters"];
fieldsToUpdate = fieldsToUpdate( ...
    isfield(updatedCode, cellstr(fieldsToUpdate)));
updatedCode = rmfield( ...
    updatedCode, ...
    setdiff(fieldnames(updatedCode), cellstr(fieldsToUpdate)));
temporaryPath = [tempname, '.mlapp'];
temporaryCleanup = onCleanup(@() deleteIfPresent(temporaryPath));
outcome = appdesigner.internal.comparison.saveAppCode( ...
    mlappPath, temporaryPath, char(source), updatedCode, true);

if string(outcome.Status) ~= "success"
    message = "Unknown App Designer serialization failure.";

    if isfield(outcome, 'Message')
        message = string(outcome.Message);
    end

    error( ...
        "OpenMebius2:Development:MlappSynchronizationFailed", ...
        "Failed to synchronize %s: %s", mlappPath, message);
end

[isCopied, copyMessage] = copyfile(temporaryPath, mlappPath, 'f');

if ~isCopied
    error( ...
        "OpenMebius2:Development:MlappCopyFailed", ...
        "Failed to replace %s: %s", mlappPath, copyMessage);
end

clear temporaryCleanup

end


function deleteIfPresent(path)

if isfile(path)
    delete(path);
end

end
