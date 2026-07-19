classdef ComparisonViewContextTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function storesDependenciesAndInitialState(testCase)

            [presenter, catalog] = ...
                ComparisonViewContextTest.dependencies();

            context = openmebius.presentation.experiment ...
                .ComparisonViewContext( ...
                    Presenter = presenter, ...
                    InitialCatalog = catalog);

            testCase.verifyEqual(context.Presenter, presenter);
            testCase.verifyEqual(context.InitialCatalog, catalog);
            testCase.verifyEqual(context.Mode, "ms");

        end

        function rejectsUnknownMode(testCase)

            [presenter, catalog] = ...
                ComparisonViewContextTest.dependencies();

            testCase.verifyError( ...
                @() openmebius.presentation.experiment ...
                    .ComparisonViewContext( ...
                        Presenter = presenter, ...
                        InitialCatalog = catalog, ...
                        Mode = "unknown"), ...
                "MATLAB:validators:mustBeMember");

        end

    end % methods (Test)

    methods (Static, Access = private)

        function [presenter, catalog] = dependencies()

            service = helpers.ExperimentComparisonServiceStub();
            service.Catalog = openmebius.application.experiment ...
                .ExperimentComparisonCatalog( ...
                    ExperimentNames = "ExpA", ...
                    DataNames = "FragA");
            experiments = helpers.ExperimentComparisonWorkspaceStub([]);
            presenter = openmebius.presentation.experiment ...
                .ComparisonViewPresenter( ...
                    experiments, Service = service);
            catalog = presenter.presentCatalog();

        end

    end % methods (Static, Access = private)

end % classdef
