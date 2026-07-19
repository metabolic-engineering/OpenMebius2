function synchronizeMlappSource(appNames, root)
%SYNCHRONIZEMLAPPSOURCE Replace mlapp document code from exported sources.

arguments
    appNames (:, 1) string
    root (1, 1) string = string(fileparts(fileparts(mfilename("fullpath"))))
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
    replaceDocumentEntry(mlappPath, source);
end

end

function replaceDocumentEntry(mlappPath, source)

xml = createDocumentXml(mlappPath, source);
NET.addAssembly('System.IO.Compression');
NET.addAssembly('System.IO.Compression.FileSystem');
mode = System.IO.Compression.ZipArchiveMode.Update;
archive = System.IO.Compression.ZipFile.Open(char(mlappPath), mode);
archiveCleanup = onCleanup(@() archive.Dispose());
entry = archive.GetEntry('matlab/document.xml');

if isempty(entry)
    error( ...
        "OpenMebius2:Development:MissingDocumentCode", ...
        "The mlapp does not contain matlab/document.xml: %s", ...
        mlappPath);
end

entry.Delete();
entry = archive.CreateEntry( ...
    'matlab/document.xml', ...
    System.IO.Compression.CompressionLevel.Optimal);
stream = entry.Open();
streamCleanup = onCleanup(@() stream.Dispose());
writer = System.IO.StreamWriter( ...
    stream, System.Text.UTF8Encoding(false));
writerCleanup = onCleanup(@() writer.Dispose());
writer.Write(xml);
writer.Flush();
clear writerCleanup streamCleanup archiveCleanup

end

function xml = createDocumentXml(mlappPath, source)

archive = java.util.zip.ZipFile(char(mlappPath));
archiveCleanup = onCleanup(@() archive.close());
entry = archive.getEntry("matlab/document.xml");

if isempty(entry)
    error( ...
        "OpenMebius2:Development:MissingDocumentCode", ...
        "The mlapp does not contain matlab/document.xml: %s", ...
        mlappPath);
end

input = archive.getInputStream(entry);
inputCleanup = onCleanup(@() input.close());
factory = javax.xml.parsers.DocumentBuilderFactory.newInstance();
document = factory.newDocumentBuilder().parse(input);
textNodes = document.getElementsByTagName("w:t");

if textNodes.getLength() == 0
    error( ...
        "OpenMebius2:Development:MissingDocumentText", ...
        "The App Designer document contains no w:t source node.");
end

textNodes.item(0).setTextContent(char(source));
transformer = javax.xml.transform.TransformerFactory ...
    .newInstance().newTransformer();
transformer.setOutputProperty( ...
    javax.xml.transform.OutputKeys.ENCODING, "UTF-8");
writer = java.io.StringWriter();
transformer.transform( ...
    javax.xml.transform.dom.DOMSource(document), ...
    javax.xml.transform.stream.StreamResult(writer));
xml = char(writer.toString());

end
