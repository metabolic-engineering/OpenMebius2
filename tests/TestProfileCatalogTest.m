classdef TestProfileCatalogTest < matlab.unittest.TestCase

    methods (Test)

        function profilesPartitionEveryKnownTest(testCase)

            fast = testProfileFiles("fast");
            domain = testProfileFiles("domain");
            numerical = testProfileFiles("numerical");
            integration = testProfileFiles("integration");
            allTests = testProfileFiles("all");
            partitioned = [fast; domain; numerical; integration];

            testCase.verifyEqual(sort(partitioned), sort(allTests));
            testCase.verifyEqual( ...
                numel(unique(partitioned)), numel(partitioned));

        end

        function isolatesGuiAndIntegrationTests(testCase)

            integration = TestProfileCatalogTest.namesOf( ...
                testProfileFiles("integration"));

            testCase.verifyTrue(any(integration == "OpenMebius2Test.m"));
            testCase.verifyTrue(any( ...
                integration == "OpenMebius2IntegratedTest.m"));
            testCase.verifyTrue(any( ...
                integration == "OpenMebius2WorkflowSmokeTest.m"));
            testCase.verifyTrue(all( ...
                integration == "OpenMebius2Test.m" | ...
                contains(integration, "IntegrationTest.m") | ...
                contains(integration, "IntegratedTest.m") | ...
                contains(integration, "WorkflowSmokeTest.m")));

        end

        function isolatesNumericalTests(testCase)

            numerical = TestProfileCatalogTest.namesOf( ...
                testProfileFiles("numerical"));
            domain = TestProfileCatalogTest.namesOf( ...
                testProfileFiles("domain"));

            testCase.verifyTrue(any( ...
                numerical == "MFAWorkflowTest.m"));
            testCase.verifyTrue(any( ...
                numerical == "EMUMDVCalculatorTest.m"));
            testCase.verifyTrue(any( ...
                numerical == "SteadyStateSolverTest.m"));
            testCase.verifyTrue(any( ...
                numerical == "MFACharacterizationTest.m"));
            testCase.verifyFalse(any(contains(domain, "IntegrationTest.m")));

        end

    end

    methods (Static, Access = private)

        function fileNames = namesOf(testFiles)

            fileNames = strings(size(testFiles));

            for fileIndex = 1:numel(testFiles)
                [~, name, extension] = fileparts(testFiles(fileIndex));
                fileNames(fileIndex) = name + extension;
            end

        end

    end

end
