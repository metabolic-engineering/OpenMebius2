function summary = formatMatlabFiles(root, options)
%FORMATMATLABFILES Format MATLAB source files throughout the project.
%
%   FORMATMATLABFILES formats MATLAB files below the src, tests, and tools
%   directories of this repository. The implementation uses the same
%   indentcode function as the official MATLAB Language Server.
%
%   App Designer review sources named *_exported.m are excluded because
%   synchronizeExportedSource regenerates them from canonical .mlapp files.
%
%   FORMATMATLABFILES(ROOT) formats files below the specified repository
%   root.
%
%   FORMATMATLABFILES(..., SourceDirectories=DIRECTORIES) selects the
%   directories below ROOT to process.
%
%   FORMATMATLABFILES(..., IncludeGenerated=true) also formats
%   *_exported.m files.
%
%   FORMATMATLABFILES(..., IndentWidth=WIDTH) sets the indentation width.
%   The default matches the VS Code editor default of four columns.
%
%   SUMMARY = FORMATMATLABFILES(...) returns the processed file lists.

arguments
    root (1, 1) string = string(fileparts(fileparts(mfilename("fullpath"))))
    options.SourceDirectories (:, 1) string = ["src"; "tests"; "tools"]
    options.IncludeGenerated (1, 1) logical = false
    options.IndentWidth (1, 1) double {mustBeInteger, mustBePositive} = 4
    options.InsertSpaces (1, 1) logical = true
end

if exist("indentcode", "file") ~= 2
    error( ...
        "OpenMebius2:Development:FormatterUnavailable", ...
        "The MATLAB indentcode formatter is not available in this release.");
end

root = normalizeRoot(root);
filePaths = findMatlabFiles(root, options.SourceDirectories);

if options.IncludeGenerated
    excludedFiles = strings(0, 1);
else
    isGenerated = endsWith(filePaths, "_exported.m", IgnoreCase=true);
    excludedFiles = filePaths(isGenerated);
    filePaths = filePaths(~isGenerated);
end

settingsRoot = settings;
insertSpacesCleanup = setTemporaryValue( ...
    settingsRoot.matlab.editor.tab.InsertSpaces, ...
    options.InsertSpaces); %#ok<NASGU>
tabSizeCleanup = setTemporaryValue( ...
    settingsRoot.matlab.editor.tab.TabSize, ...
    options.IndentWidth); %#ok<NASGU>
indentSizeCleanup = setTemporaryValue( ...
    settingsRoot.matlab.editor.tab.IndentSize, ...
    options.IndentWidth); %#ok<NASGU>

formattedFiles = strings(0, 1);
unchangedFiles = strings(0, 1);
failedFiles = strings(0, 1);
failureMessages = strings(0, 1);

for fileIndex = 1:numel(filePaths)
    filePath = filePaths(fileIndex);

    try
        [originalText, hasByteOrderMark] = readUtf8(filePath);
        formattedText = formatText(originalText);

        if strcmp(originalText, formattedText)
            unchangedFiles(end + 1, 1) = filePath; %#ok<AGROW>
        else
            writeUtf8Atomically( ...
                filePath, ...
                formattedText, ...
                hasByteOrderMark);
            formattedFiles(end + 1, 1) = filePath; %#ok<AGROW>
        end
    catch exception
        failedFiles(end + 1, 1) = filePath; %#ok<AGROW>
        failureMessages(end + 1, 1) = string(exception.message); %#ok<AGROW>
    end
end

summary = struct( ...
    "Root", root, ...
    "FormattedFiles", makeRelative(formattedFiles, root), ...
    "UnchangedFiles", makeRelative(unchangedFiles, root), ...
    "ExcludedFiles", makeRelative(excludedFiles, root), ...
    "FailedFiles", makeRelative(failedFiles, root), ...
    "FailureMessages", failureMessages);

fprintf( ...
    "MATLAB formatting complete: %d formatted, %d unchanged, " + ...
    "%d excluded, %d failed.\n", ...
    numel(formattedFiles), ...
    numel(unchangedFiles), ...
    numel(excludedFiles), ...
    numel(failedFiles));

if ~isempty(failedFiles)
    details = join(summary.FailedFiles + ": " + failureMessages, newline);
    error( ...
        "OpenMebius2:Development:FormattingFailed", ...
        "Formatting failed for %d file(s):\n%s", ...
        numel(failedFiles), ...
        details);
end

end


function root = normalizeRoot(root)

if ~isfolder(root)
    error( ...
        "OpenMebius2:Development:MissingFormattingRoot", ...
        "The formatting root does not exist: %s", ...
        root);
end

root = string(java.io.File(char(root)).getCanonicalPath());

end


function filePaths = findMatlabFiles(root, sourceDirectories)

filePaths = strings(0, 1);

for directoryIndex = 1:numel(sourceDirectories)
    sourceDirectory = fullfile(root, sourceDirectories(directoryIndex));

    if ~isfolder(sourceDirectory)
        error( ...
            "OpenMebius2:Development:MissingSourceDirectory", ...
            "The MATLAB source directory does not exist: %s", ...
            sourceDirectory);
    end

    entries = dir(fullfile(sourceDirectory, "**", "*.m"));

    if isempty(entries)
        continue
    end

    directoryFiles = string(fullfile( ...
        {entries.folder}.', ...
        {entries.name}.'));
    filePaths = [filePaths; directoryFiles]; %#ok<AGROW>
end

filePaths = sort(unique(filePaths));

end


function formattedText = formatText(originalText)

lineEnding = detectLineEnding(originalText);
normalizedText = regexprep( ...
    originalText, ...
    '(\r\n)|\r|\n', ...
    newline);
formattedText = indentcode(normalizedText);
formattedText = regexprep( ...
    formattedText, ...
    '(\r\n)|\r|\n', ...
    newline);

if ~strcmp(lineEnding, newline)
    formattedText = strrep(formattedText, newline, lineEnding);
end

end


function lineEnding = detectLineEnding(text)

if contains(text, sprintf('\r\n'))
    lineEnding = sprintf('\r\n');
elseif contains(text, newline)
    lineEnding = newline;
elseif contains(text, sprintf('\r'))
    lineEnding = sprintf('\r');
else
    lineEnding = newline;
end

end


function [text, hasByteOrderMark] = readUtf8(path)

fileID = fopen(path, 'r');

if fileID < 0
    error( ...
        "OpenMebius2:Development:FormatReadFailed", ...
        "Could not open the MATLAB file for reading: %s", ...
        path);
end

fileCleanup = onCleanup(@() fcloseIfOpen(fileID));
bytes = fread(fileID, Inf, '*uint8').';
fclose(fileID);
clear fileCleanup

byteOrderMark = uint8([239, 187, 191]);
hasByteOrderMark = numel(bytes) >= numel(byteOrderMark) && ...
    isequal(bytes(1:numel(byteOrderMark)), byteOrderMark);

if hasByteOrderMark
    bytes = bytes(numel(byteOrderMark) + 1:end);
end

text = native2unicode(bytes, 'UTF-8');

end


function writeUtf8Atomically(path, text, hasByteOrderMark)

temporaryPath = string(tempname(fileparts(path))) + ".m";
temporaryCleanup = onCleanup(@() deleteIfPresent(temporaryPath));
fileID = fopen(temporaryPath, 'w');

if fileID < 0
    error( ...
        "OpenMebius2:Development:FormatWriteFailed", ...
        "Could not open a temporary formatting file for %s.", ...
        path);
end

fileCleanup = onCleanup(@() fcloseIfOpen(fileID));
bytes = unicode2native(text, 'UTF-8');

if hasByteOrderMark
    bytes = [uint8([239, 187, 191]), bytes];
end

fwrite(fileID, bytes, 'uint8');
fclose(fileID);
clear fileCleanup

[wasMoved, moveMessage] = movefile(temporaryPath, path, 'f');

if ~wasMoved
    error( ...
        "OpenMebius2:Development:FormatMoveFailed", ...
        "Could not replace %s: %s", ...
        path, ...
        moveMessage);
end

clear temporaryCleanup

end


function cleanup = setTemporaryValue(setting, temporaryValue)

if setting.hasTemporaryValue
    originalValue = setting.TemporaryValue;
    cleanup = onCleanup(@() setValue(setting, originalValue));
else
    cleanup = onCleanup(@() setting.clearTemporaryValue());
end

setting.TemporaryValue = temporaryValue;

end


function setValue(setting, value)

setting.TemporaryValue = value;

end


function relativePaths = makeRelative(filePaths, root)

rootPrefix = root + filesep;
relativePaths = erase(filePaths, rootPrefix);

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
