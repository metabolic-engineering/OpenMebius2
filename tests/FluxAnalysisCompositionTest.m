classdef FluxAnalysisCompositionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(FluxAnalysisCompositionTest.sourcePath());

        end

    end

    methods (Test)

        function defaultsProvideProductionServices(testCase)

            composition = openmebius.application.analysis ...
                .FluxAnalysisComposition();

            testCase.verifyEmpty(composition.RuntimeFactory);
            testCase.verifyEmpty(composition.RunContext);
            testCase.verifyClass( ...
                composition.Hdf5ResultRepository, ...
                'openmebius.infrastructure.result.Hdf5ResultRepository');
            testCase.verifyClass( ...
                composition.ResultManifestRepository, ...
                ['openmebius.infrastructure.result.' ...
                'ResultManifestRepository']);
            testCase.verifyClass( ...
                composition.FluxVariabilitySolver, ...
                'openmebius.mfa.FluxVariabilitySolver');
            testCase.verifyClass( ...
                composition.MFAWorkflow, ...
                'openmebius.mfa.MFAWorkflow');
            testCase.verifyClass( ...
                composition.MFAInputValidator, ...
                'openmebius.mfa.MFAInputValidator');

        end

        function overridesAreRetained(testCase)

            runtimeFactory = struct(Name = "runtime");
            workflow = struct(Name = "workflow");
            initialWorkflow = struct(Name = "initial-workflow");
            runContext = openmebius.application.analysis ...
                .MFAAnalysisRunContext();
            composition = openmebius.application.analysis ...
                .FluxAnalysisComposition( ...
                RuntimeFactory = runtimeFactory, ...
                FluxDistributionWorkflow = workflow, ...
                InitialFluxApplicationWorkflow = initialWorkflow, ...
                RunContext = runContext);

            testCase.verifyEqual( ...
                composition.RuntimeFactory, runtimeFactory);
            testCase.verifyEqual( ...
                composition.FluxDistributionWorkflow, workflow);
            testCase.verifyEqual( ...
                composition.InitialFluxApplicationWorkflow, ...
                initialWorkflow);
            testCase.verifyEqual(composition.RunContext, runContext);

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
