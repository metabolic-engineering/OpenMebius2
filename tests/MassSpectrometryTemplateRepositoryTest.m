classdef MassSpectrometryTemplateRepositoryTest < matlab.unittest.TestCase

    properties
        TestDirectory (1, 1) string
    end

    methods (TestMethodSetup)

        function createTestDirectory(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            testCase.TestDirectory = string(tempname);
            mkdir(testCase.TestDirectory);

        end

    end

    methods (TestMethodTeardown)

        function removeTestDirectory(testCase)

            if isfolder(testCase.TestDirectory)
                rmdir(testCase.TestDirectory, "s");
            end

        end

    end

    methods (Test)

        function atomicallyWritesWorkbook(testCase)

            repository = openmebius.infrastructure.model ...
                .MassSpectrometryTemplateRepository();
            outputPath = fullfile( ...
                testCase.TestDirectory, "template.xlsx");
            writematrix(99, outputPath, Sheet = "MS");

            repository.write( ...
                outputPath, [1, 2; 3, 4], SheetName = "MS");

            testCase.verifyEqual( ...
                readmatrix(outputPath, Sheet = "MS"), ...
                [1, 2; 3, 4]);

        end

        function preservesExistingWorkbookWhenWriteFails(testCase)

            repository = openmebius.infrastructure.model ...
                .MassSpectrometryTemplateRepository();
            outputPath = fullfile( ...
                testCase.TestDirectory, "template.xlsx");
            writematrix(99, outputPath, Sheet = "MS");

            testCase.verifyError( ...
                @() repository.write( ...
                outputPath, struct("Value", 1), SheetName = "MS"), ...
                "OpenMebius2:MSTemplate:WriteFailed");
            testCase.verifyEqual( ...
                readmatrix(outputPath, Sheet = "MS"), 99);

            files = dir(fullfile(testCase.TestDirectory, "*.xlsx"));
            testCase.verifyEqual(string({files.name}), "template.xlsx");

        end

    end % methods (Test)

end % classdef
