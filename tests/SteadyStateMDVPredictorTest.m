classdef SteadyStateMDVPredictorTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(SteadyStateMDVPredictorTest.sourcePath());

        end

    end

    methods (Test)

        function predictsMDVColumnsForEachExperiment(testCase)

            predictor = openmebius.mfa.SteadyStateMDVPredictor();

            result = predictor.predictByExperiment( ...
                helpers.SteadyStateModelStub(), ...
                [0.2; 0.7], ...
                {eye(2), 2 * eye(2)});

            testCase.verifyEqual( ...
                result, ...
                [0.2, 0.4; 0.7, 1.4], ...
                AbsTol = 1e-12);

        end

        function linearizesMDVByExperimentColumn(testCase)

            predictor = openmebius.mfa.SteadyStateMDVPredictor();

            result = predictor.predictLinearized( ...
                helpers.SteadyStateModelStub(), ...
                [0.2; 0.7], ...
                {eye(2), 2 * eye(2)});

            testCase.verifyEqual( ...
                result, ...
                [0.2; 0.7; 0.4; 1.4], ...
                AbsTol = 1e-12);

        end

        function rejectsDifferentFragmentCounts(testCase)

            predictor = openmebius.mfa.SteadyStateMDVPredictor();

            testCase.verifyError( ...
                @() predictor.predictByExperiment( ...
                helpers.SteadyStateModelStub(), ...
                [0.2; 0.7], ...
                {eye(2), [1, 0]}), ...
                "OpenMebius2:SteadyStateMDVPredictor:" + ...
                "FragmentCountMismatch");

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
