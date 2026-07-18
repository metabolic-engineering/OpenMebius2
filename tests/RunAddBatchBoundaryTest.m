classdef RunAddBatchBoundaryTest < matlab.unittest.TestCase

    methods (Test)

        function childAppUsesSingleContext(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            source = string(fileread( ...
                fullfile(root, "src", "RunAddBatch_exported.m")));

            testCase.verifyTrue(contains( ...
                source, "startupFcn(app, context)"));
            testCase.verifyTrue(contains(source, "context.Editor"));
            testCase.verifyFalse(contains( ...
                source, ...
                "startupFcn(app, experimentNames, type, batchID)"));
            testCase.verifyFalse(contains(source, "app.type"));
            testCase.verifyFalse(contains(source, "app.batchID"));

        end

        function bothParentsConstructContext(testCase)

            root = fileparts(fileparts(mfilename("fullpath")));
            parentFiles = ["OpenMebius2_exported.m", ...
                "RunConfig_exported.m"];

            for fileIndex = 1:numel(parentFiles)
                source = string(fileread( ...
                    fullfile(root, "src", parentFiles(fileIndex))));
                testCase.verifyTrue(contains( ...
                    source, ".RunAddBatchContext(Editor = viewModel)"), ...
                    parentFiles(fileIndex));
                testCase.verifyTrue(contains( ...
                    source, "RunAddBatch(context)"), ...
                    parentFiles(fileIndex));
            end

        end

    end % methods (Test)

end % classdef
