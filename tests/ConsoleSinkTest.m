classdef ConsoleSinkTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function separatesStandardOutputAndStandardError(testCase)

            output = strings(0, 1);
            errors = strings(0, 1);
            sink = openmebius.infrastructure.notification.ConsoleSink( ...
                OutputWriter = @recordOutput, ...
                ErrorWriter = @recordError);

            sink.write(openmebius.core.notification.Message( ...
                "ready", "info", EventId = "console-info"));
            sink.write(openmebius.core.notification.Message( ...
                "problem", "warning", EventId = "console-warning"));

            testCase.verifyNumElements(output, 1);
            testCase.verifyTrue(contains(output, "[INFO]"));
            testCase.verifyTrue(contains(output, "ready"));
            testCase.verifyNumElements(errors, 1);
            testCase.verifyTrue(contains(errors, "[WARNING]"));
            testCase.verifyTrue(contains(errors, "problem"));

            function recordOutput(text)
                output(end + 1, 1) = string(text);
            end

            function recordError(text)
                errors(end + 1, 1) = string(text);
            end

        end

    end

end
