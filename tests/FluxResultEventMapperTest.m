classdef FluxResultEventMapperTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(FluxResultEventMapperTest.sourcePath());

        end

    end

    methods (Test)

        function mapsBestIterationAndLegacyPayload(testCase)

            result = FluxResultEventMapperTest.sampleResult();
            timestamp = datetime( ...
                2026, 7, 15, 10, 20, 30, ...
                "TimeZone", "UTC");

            eventData = openmebius.presentation.result ...
                .FluxResultEventMapper.fromSessionResult( ...
                result, Timestamp = timestamp);

            testCase.verifyClass( ...
                eventData, ...
                'openmebius.presentation.result.FluxResultEventData');
            testCase.verifyEqual(eventData.ID, "batch-1");
            testCase.verifyEqual(eventData.FVAUpperBounds, [5; 6]);
            testCase.verifyEqual(eventData.FVALowerBounds, [1; 2]);
            testCase.verifyEqual(eventData.RSSIndices, [2, 1]);
            testCase.verifyEqual(eventData.Flux, [7; 8]);
            testCase.verifyEqual(eventData.RSS, 3.5);
            testCase.verifyEqual(eventData.MDV, [0.3; 0.7]);
            testCase.verifyEqual(eventData.ExitFlag, 1);
            testCase.verifyEqual(eventData.data.ID, "batch-1");
            testCase.verifyEqual(eventData.data.FVA_UB, [5; 6]);
            testCase.verifyEqual(eventData.data.FVA_LB, [1; 2]);
            testCase.verifyEqual(eventData.data.time, posixtime(timestamp));

        end

        function missingBestIterationIsRejected(testCase)

            result = rmfield( ...
                FluxResultEventMapperTest.sampleResult(), ...
                'fluxResult0002');

            testCase.verifyError( ...
                @() openmebius.presentation.result ...
                .FluxResultEventMapper.fromSessionResult(result), ...
                "OpenMebius2:FluxResultEventMapper:MissingField");

        end

        function emptyIterationOrderIsRejected(testCase)

            result = FluxResultEventMapperTest.sampleResult();
            result.RSSIdx = [];

            testCase.verifyError( ...
                @() openmebius.presentation.result ...
                .FluxResultEventMapper.fromSessionResult(result), ...
                "OpenMebius2:FluxResultEventMapper:EmptyRSSOrder");

        end

        function invalidBestIterationIsRejected(testCase)

            result = FluxResultEventMapperTest.sampleResult();
            result.RSSIdx = [1.5, 1];

            testCase.verifyError( ...
                @() openmebius.presentation.result ...
                .FluxResultEventMapper.fromSessionResult(result), ...
                "OpenMebius2:FluxResultEventMapper:" + ...
                "InvalidBestIteration");

        end

    end

    methods (Static, Access = private)

        function result = sampleResult()

            result = struct;
            result.ID = "batch-1";
            result.fluxVariability = struct( ...
                fluxUB = [5; 6], ...
                fluxLB = [1; 2]);
            result.RSSIdx = [2, 1];
            result.fluxResult0002 = struct( ...
                flux = [7; 8], ...
                RSS = 3.5, ...
                MDV = [0.3; 0.7], ...
                exitflag = 1);

        end

        function path = sourcePath()

            path = fullfile( ...
                fileparts(fileparts(mfilename('fullpath'))), ...
                'src');

        end

    end

end
