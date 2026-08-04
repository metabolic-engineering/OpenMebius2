function synchronizeExportedSource(appNames, root)
%SYNCHRONIZEEXPORTEDSOURCE Refresh review sources from canonical mlapp files.

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
    mlappPath = fullfile(root, "src", appName + ".mlapp");
    exportedPath = fullfile( ...
        root, "src", appName + "_exported.m");

    if ~isfile(mlappPath)
        error( ...
            "OpenMebius2:Development:MissingAppSource", ...
            "The App Designer source is missing: %s", ...
            mlappPath);
    end

    reader = appdesigner.internal.serialization.FileReader( ...
        char(mlappPath));
    source = string(reader.readMATLABCodeText());
    source = renameExportedClass(source, appName);
    source = regexprep(source, '[ \t]+(?=\r?\n|$)', '');
    writeUtf8Atomically(exportedPath, source);
end

end

function source = renameExportedClass(source, appName)

classDeclaration = "classdef " + appName + " <";
exportedClassDeclaration = ...
    "classdef " + appName + "_exported <";
constructorDeclaration = ...
    "function app = " + appName + "(varargin)";
exportedConstructorDeclaration = ...
    "function app = " + appName + "_exported(varargin)";

if count(source, classDeclaration) ~= 1 || ...
        count(source, constructorDeclaration) ~= 1
    error( ...
        "OpenMebius2:Development:UnexpectedAppSource", ...
        "Could not identify the class and constructor for %s.", ...
        appName);
end

source = replace( ...
    source, classDeclaration, exportedClassDeclaration);
source = replace( ...
    source, constructorDeclaration, exportedConstructorDeclaration);

end

function writeUtf8Atomically(path, source)

temporaryPath = string(tempname(fileparts(path))) + ".m";
temporaryCleanup = onCleanup(@() deleteIfPresent(temporaryPath));
fileID = fopen(temporaryPath, 'w');

if fileID < 0
    error( ...
        "OpenMebius2:Development:ExportWriteFailed", ...
        "Could not open a temporary export file for %s.", ...
        path);
end

fileCleanup = onCleanup(@() fcloseIfOpen(fileID));
fwrite( ...
    fileID, ...
    unicode2native(char(source), 'UTF-8'), ...
    'uint8');
fclose(fileID);
clear fileCleanup

[wasMoved, moveMessage] = movefile( ...
    temporaryPath, path, 'f');

if ~wasMoved
    error( ...
        "OpenMebius2:Development:ExportMoveFailed", ...
        "Could not replace %s: %s", path, moveMessage);
end

clear temporaryCleanup

end

function fcloseIfOpen(fileID)

try
    fclose(fileID);
catch
end

end

function deleteIfPresent(path)

if isfile(path)
    delete(path);
end

end
