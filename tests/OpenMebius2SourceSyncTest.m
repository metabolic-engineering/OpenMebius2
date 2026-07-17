classdef OpenMebius2SourceSyncTest < matlab.unittest.TestCase

    methods (Test)

        function mlappCodeMatchesExportedSource(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            mlappPath = fullfile(root, "src", "OpenMebius2.mlapp");
            archive = java.util.zip.ZipFile(mlappPath);
            archiveCleanup = onCleanup(@() archive.close());
            documentEntry = archive.getEntry("matlab/document.xml");
            testCase.assertNotEmpty(documentEntry);
            documentStream = archive.getInputStream(documentEntry);
            streamCleanup = onCleanup(@() documentStream.close());
            factory = javax.xml.parsers.DocumentBuilderFactory.newInstance();
            document = factory.newDocumentBuilder().parse(documentStream);
            textNodes = document.getElementsByTagName("w:t");
            testCase.assertGreaterThan(textNodes.getLength(), 0);
            mlappCode = string(textNodes.item(0).getTextContent());
            exportedCode = string(fileread( ...
                fullfile(root, "src", "OpenMebius2_exported.m")));
            exportedCode = replace( ...
                exportedCode, "OpenMebius2_exported", "OpenMebius2");

            testCase.verifyEqual( ...
                OpenMebius2SourceSyncTest.normalizeCode(mlappCode), ...
                OpenMebius2SourceSyncTest.normalizeCode(exportedCode));
            testCase.verifyNotEmpty( ...
                archive.getEntry("appdesigner/appModel.mat"));

        end

    end % methods (Test)

    methods (Static, Access = private)

        function code = normalizeCode(code)

            code = replace(string(code), compose("\r\n"), newline);
            code = replace(code, compose("\r"), newline);
            code = strip(code, "right");

        end

    end % methods (Static, Access = private)

end % classdef
