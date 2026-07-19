classdef TemplateModelLoadServiceTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            addpath(TemplateModelLoadServiceTest.sourcePath());

        end

    end

    methods (Test)

        function loadBuildsModelFromTemplateDirectory(testCase)

            modelLocation = openmebius.domain.model.ModelLocation ...
                .fromDirectory( ...
                TemplateModelLoadServiceTest.templateModelDirectory());

            service = openmebius.application.model.TemplateModelLoadService();

            result = service.load(modelLocation);

            testCase.verifyClass( ...
                result, ...
                "openmebius.application.model.TemplateModelLoadResult");
            testCase.verifyClass( ...
                result.Model, ...
                "openmebius.application.model.MetabolicModel");
            testCase.verifyEqual( ...
                result.ModelLocation.Directory, ...
                modelLocation.Directory);
            testCase.verifyGreaterThanOrEqual(numel(result.Messages), 2);

        end

        function loadRejectsMissingDirectory(testCase)

            modelLocation = openmebius.domain.model.ModelLocation ...
                .fromDirectory(fullfile(tempdir, "missing-openmebius-model"));

            service = openmebius.application.model.TemplateModelLoadService();

            testCase.verifyError( ...
                @() service.load(modelLocation), ...
                "OpenMebius2:TemplateModel:DirectoryNotFound");

        end

        function loadRejectsEmptyDirectory(testCase)

            modelDirectory = string(tempname);
            mkdir(modelDirectory);
            cleanup = onCleanup(@() ...
                TemplateModelLoadServiceTest.removeDirectory(modelDirectory));

            modelLocation = openmebius.domain.model.ModelLocation ...
                .fromDirectory(modelDirectory);

            service = openmebius.application.model.TemplateModelLoadService();

            testCase.verifyError( ...
                @() service.load(modelLocation), ...
                "OpenMebius2:TemplateModel:DirectoryEmpty");

        end

    end

    methods (Static, Access = private)

        function path = sourcePath()

            path = fullfile( ...
                TemplateModelLoadServiceTest.repositoryRoot(), ...
                "src");

        end

        function path = templateModelDirectory()

            path = fullfile( ...
                TemplateModelLoadServiceTest.repositoryRoot(), ...
                "tutorial", ...
                "ecoli", ...
                "model");

        end

        function path = repositoryRoot()

            path = fileparts(fileparts(mfilename("fullpath")));

        end

        function removeDirectory(directory)

            if isfolder(directory)
                rmdir(directory, "s");
            end

        end

    end

end
