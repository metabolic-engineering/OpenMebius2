classdef CIFastTestSuiteTest < matlab.unittest.TestCase

    methods (Test)

        function containsRequiredBoundaryChecks(testCase)

            [suite, testFiles] = ciFastTestSuite();
            testNames = string({suite.Name});
            fileNames = strings(size(testFiles));

            for fileIndex = 1:numel(testFiles)
                [~, name, extension] = fileparts(testFiles(fileIndex));
                fileNames(fileIndex) = name + extension;
            end

            testCase.verifyNotEmpty(suite);
            testCase.verifyTrue(any(contains( ...
                testNames, "MainAppCompositionBoundaryTest")));
            testCase.verifyTrue(any(fileNames == ...
                "MainAppCompositionRootTest.m"));
            testCase.verifyTrue(any(fileNames == ...
                "MainApplicationSessionTest.m"));
            testCase.verifyTrue(any(fileNames == ...
                "OpenMebius2SourceSyncTest.m"));

        end

        function excludesSlowIntegrationTests(testCase)

            [~, testFiles] = ciFastTestSuite();

            testCase.verifyFalse(any(contains( ...
                testFiles, "IntegrationTest.m")));
            testCase.verifyFalse(any(contains( ...
                testFiles, "IntegratedTest.m")));

        end

    end

end
