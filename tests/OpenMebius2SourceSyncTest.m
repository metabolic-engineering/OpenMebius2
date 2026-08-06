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

        function labelConfigCodeMatchesExportedSource(testCase)

            OpenMebius2SourceSyncTest.verifyAppSource( ...
                testCase, "LabelConfig");

        end

        function tracerConfigCodeMatchesExportedSource(testCase)

            OpenMebius2SourceSyncTest.verifyAppSource( ...
                testCase, "TracerConfig");

        end

        function comparisonViewCodeMatchesExportedSource(testCase)

            OpenMebius2SourceSyncTest.verifyAppSource( ...
                testCase, "ComparisonView");

        end

        function viewSuggestionCodeMatchesExportedSource(testCase)

            OpenMebius2SourceSyncTest.verifyAppSource( ...
                testCase, "ViewSuggestion");

        end

        function viewComparisonCodeMatchesExportedSource(testCase)

            OpenMebius2SourceSyncTest.verifyAppSource( ...
                testCase, "ViewComparison");

        end

        function legacyParserDoesNotProduceFalseMismatch(testCase)

            parser = helpers.LegacyPlainTextCodeParserStub();
            callbackInfo = struct( ...
                AssignedCallbacks = [], ...
                Children = struct.empty);
            [codeData, isSupported] = ...
                OpenMebius2SourceSyncTest.tryParseCodeData( ...
                parser, callbackInfo, "startupFcn", true, "Standard");

            testCase.verifyFalse(isSupported);
            testCase.verifyEmpty(codeData);

        end

        function editableSectionBoundaryBlankLinesAreIgnored(testCase)

            actual = {'', 'properties', ''};
            expected = {'', '', 'properties', '', ''};

            testCase.verifyEqual( ...
                OpenMebius2SourceSyncTest.normalizeCodeData(actual), ...
                OpenMebius2SourceSyncTest.normalizeCodeData(expected));

        end

        function allMlappCodeStoresAreSynchronized(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            appFiles = dir(fullfile(root, "src", "*.mlapp"));
            appNames = sort(string({appFiles.name}));

            testCase.assertNotEmpty(appNames);

            for appIndex = 1:numel(appNames)
                mlappPath = char(fullfile(root, "src", appNames(appIndex)));
                [~, appName] = fileparts(mlappPath);
                exportedPath = fullfile( ...
                    root, "src", appName + "_exported.m");
                testCase.assertTrue( ...
                    isfile(exportedPath), ...
                    "Missing exported source for " + appNames(appIndex));
                OpenMebius2SourceSyncTest.verifyAppSource( ...
                    testCase, string(appName));
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
                OpenMebius2SourceSyncTest.normalizeCode(exportedCode), ...
                "appModel.mat mismatch in " + appName);

            [actualCodeData, expectedCodeData, isParserSupported] = ...
                OpenMebius2SourceSyncTest.appModelCodeData( ...
                testCase, mlappPath, exportedCode);

            if isParserSupported
                fields = [ ...
                              "ClassName", ...
                              "EditableSectionCode", ...
                              "Callbacks", ...
                              "StartupCallback", ...
                          "InputParameters"];

                for fieldIndex = 1:numel(fields)
                    field = fields(fieldIndex);
                    testCase.verifyEqual( ...
                        OpenMebius2SourceSyncTest.normalizeCodeData( ...
                        actualCodeData.(field)), ...
                        OpenMebius2SourceSyncTest.normalizeCodeData( ...
                        expectedCodeData.(field)), ...
                        "appModel.mat mismatch in " + appName + ...
                        ": " + field);
                end

            end

            mlappCode = OpenMebius2SourceSyncTest.readDocumentCode( ...
                testCase, mlappPath);
            testCase.verifyEqual( ...
                OpenMebius2SourceSyncTest.normalizeCode(mlappCode), ...
                OpenMebius2SourceSyncTest.normalizeCode(exportedCode), ...
                "document.xml mismatch in " + appName);

        end % verifyAppSource

        function code = readAppModelCode(testCase, mlappPath)

            [loadOutcome, ~, ~, code] = ...
                appdesigner.internal.comparison.getAppCode(mlappPath);
            diagnostic = "Unable to read appModel.mat.";

            if isfield(loadOutcome, 'Message')
                diagnostic = diagnostic + " " + ...
                    string(loadOutcome.Message);
            end

            testCase.assertEqual( ...
                string(loadOutcome.Status), "success", diagnostic);

        end % readAppModelCode

        function [actual, expected, isParserSupported] = ...
                appModelCodeData(testCase, mlappPath, exportedCode)

            [actual, ~, metadata] = ...
                appdesigner.internal.comparison.getAppData(mlappPath);
            parser = appdesigner.internal.serialization ...
                .PlainTextCodeParser(exportedCode);
            callbackInfo = struct( ...
                AssignedCallbacks = actual.Callbacks, ...
                Children = struct.empty);
            startupName = "";

            if isfield(actual, 'StartupCallback') && ...
                    ~isempty(actual.StartupCallback)
                startupName = string(actual.StartupCallback.Name);
            end

            isSingleton = isfield(actual, 'SingletonMode') && ...
                strcmp(actual.SingletonMode, 'FOCUS');
            appType = "Standard";

            if isfield(metadata, 'AppType')
                appType = string(metadata.AppType);
            end

            [expected, isParserSupported] = ...
                OpenMebius2SourceSyncTest.tryParseCodeData( ...
                parser, callbackInfo, startupName, isSingleton, appType);

            if ~isParserSupported
                return
            end

            if isfield(expected, 'StartupFcn')
                expected.StartupCallback = expected.StartupFcn;
                expected = rmfield(expected, 'StartupFcn');
            end

            requiredFields = [ ...
                                  "ClassName", ...
                                  "EditableSectionCode", ...
                                  "Callbacks", ...
                                  "StartupCallback", ...
                              "InputParameters"];
            defaults = struct( ...
                EditableSectionCode = {{}}, ...
                Callbacks = [], ...
                StartupCallback = [], ...
                InputParameters = []);

            for fieldIndex = 1:numel(requiredFields)
                field = requiredFields(fieldIndex);

                if ~isfield(actual, field) && isfield(defaults, field)
                    actual.(field) = defaults.(field);
                end

                if ~isfield(expected, field) && isfield(defaults, field)
                    expected.(field) = defaults.(field);
                end

                testCase.assertTrue( ...
                    isfield(actual, field), ...
                    "Missing appModel field: " + field);
                testCase.assertTrue( ...
                    isfield(expected, field), ...
                    "Missing parsed source field: " + field);
            end

        end % appModelCodeData

        function [codeData, isSupported] = tryParseCodeData( ...
                parser, callbackInfo, startupName, isSingleton, appType)

            isSupported = true;

            try
                codeData = parser.parseCodeData( ...
                    callbackInfo, startupName, isSingleton, appType);
            catch exception

                if ~strcmp(exception.identifier, "MATLAB:TooManyInputs")
                    rethrow(exception);
                end

                codeData = [];
                isSupported = false;
            end

        end % tryParseCodeData

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
            code = regexprep(code, '[ \t]+(?=\n|$)', '');
            code = strip(code, "right");

        end

        function value = normalizeCodeData(value)

            if ischar(value)
                value = char( ...
                    OpenMebius2SourceSyncTest.normalizeCode(value));
                return
            end

            if isstring(value)
                value = OpenMebius2SourceSyncTest.normalizeCode(value);
                return
            end

            if iscell(value)

                for valueIndex = 1:numel(value)
                    value{valueIndex} = OpenMebius2SourceSyncTest ...
                        .normalizeCodeData(value{valueIndex});
                end

                if isvector(value)
                    value = value(:);

                    while numel(value) > 1 && ...
                            ischar(value{1}) && isempty(value{1})
                        value(1) = [];
                    end

                    while numel(value) > 1 && ...
                            ischar(value{end}) && isempty(value{end})
                        value(end) = [];
                    end

                end

                if isscalar(value) && ischar(value{1}) && ...
                        isempty(value{1})
                    value = '';
                    return
                end

                return
            end

            if isstruct(value)
                fields = fieldnames(value);

                for valueIndex = 1:numel(value)

                    for fieldIndex = 1:numel(fields)
                        field = fields{fieldIndex};
                        value(valueIndex).(field) = ...
                            OpenMebius2SourceSyncTest ...
                            .normalizeCodeData( ...
                            value(valueIndex).(field));
                    end

                end

            end

        end

    end % methods (Static, Access = private)

end % classdef
