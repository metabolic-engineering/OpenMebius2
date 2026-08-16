classdef GridSearchParallelPoolManagerTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(GridSearchParallelPoolManagerTest.sourcePath());

        end

    end

    methods (Test)

        function limitsWorkersToSmallestResourceCount(testCase)

            manager = openmebius.mfa.GridSearchParallelPoolManager();

            testCase.verifyEqual( ...
                manager.requestedWorkerCount(20, 16, 5), 5);
            testCase.verifyEqual( ...
                manager.requestedWorkerCount(20, 4, 12), 4);
            testCase.verifyEqual( ...
                manager.requestedWorkerCount(8, 16, 12), 8);

        end

        function detectsPositiveProcessorCounts(testCase)

            [physicalCores, logicalProcessors] = openmebius.mfa ...
                .GridSearchParallelPoolManager.processorCounts();

            testCase.verifyGreaterThanOrEqual(physicalCores, 1);
            testCase.verifyGreaterThanOrEqual( ...
                logicalProcessors, physicalCores);

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
