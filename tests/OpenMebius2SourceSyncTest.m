classdef OpenMebius2SourceSyncTest < matlab.unittest.TestCase

    methods (Test)

        function mlappCodeMatchesExportedSource(testCase)

            OpenMebius2SourceSyncTest.verifyAppSource( ...
                testCase, "OpenMebius2");

        end

        function runAddBatchCodeMatchesExportedSource(testCase)

            OpenMebius2SourceSyncTest.verifyAppSource( ...
                testCase, "RunAddBatch");

        end

        function runConfigCodeMatchesExportedSource(testCase)

            OpenMebius2SourceSyncTest.verifyAppSource( ...
                testCase, "RunConfig");

        end

        function msViewCodeMatchesExportedSource(testCase)

            OpenMebius2SourceSyncTest.verifyAppSource( ...
                testCase, "MSView");

        end

        function allMlappCodeStoresAreSynchronized(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            appFiles = dir(fullfile(root, "src", "*.mlapp"));
            appNames = sort(string({appFiles.name}));

            testCase.assertNotEmpty(appNames);

            for appIndex = 1:numel(appNames)
                mlappPath = char(fullfile(root, "src", appNames(appIndex)));
                appModelCode = OpenMebius2SourceSyncTest.readAppModelCode( ...
                    testCase, mlappPath);
                documentCode = OpenMebius2SourceSyncTest.readDocumentCode( ...
                    testCase, mlappPath);

                testCase.verifyEqual( ...
                    OpenMebius2SourceSyncTest.normalizeCode(appModelCode), ...
                    OpenMebius2SourceSyncTest.normalizeCode(documentCode), ...
                    "Internal code mismatch in " + appNames(appIndex));
            end

        end

    end % methods (Test)

    methods (Static, Access = private)

        function verifyAppSource(testCase, appName)

            root = fileparts(fileparts(mfilename("fullpath")));
            mlappPath = char(fullfile(root, "src", appName + ".mlapp"));
            exportedCode = string(fileread( ...
                fullfile(root, "src", appName + "_exported.m")));
            exportedCode = replace( ...
                exportedCode, appName + "_exported", appName);

            appModelCode = OpenMebius2SourceSyncTest.readAppModelCode( ...
                testCase, mlappPath);
            testCase.verifyEqual( ...
                OpenMebius2SourceSyncTest.normalizeCode(appModelCode), ...
                OpenMebius2SourceSyncTest.normalizeCode(exportedCode));

            mlappCode = OpenMebius2SourceSyncTest.readDocumentCode( ...
                testCase, mlappPath);
            testCase.verifyEqual( ...
                OpenMebius2SourceSyncTest.normalizeCode(mlappCode), ...
                OpenMebius2SourceSyncTest.normalizeCode(exportedCode));

        end % verifyAppSource

        function code = readAppModelCode(testCase, mlappPath)

            [loadOutcome, ~, ~, code] = ...
                appdesigner.internal.comparison.getAppCode(mlappPath);
            testCase.assertEqual(string(loadOutcome.Status), "success");

        end % readAppModelCode

        function code = readDocumentCode(testCase, mlappPath)

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
            code = string(textNodes.item(0).getTextContent());
            testCase.verifyNotEmpty( ...
                archive.getEntry("appdesigner/appModel.mat"));

        end % readDocumentCode

        function code = normalizeCode(code)

            code = replace(string(code), compose("\r\n"), newline);
            code = replace(code, compose("\r"), newline);
            code = strip(code, "right");

        end

    end % methods (Static, Access = private)

end % classdef
