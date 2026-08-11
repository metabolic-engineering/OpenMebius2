classdef MainUIPolicyTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function duplicateProjectRequiresLoadedProject(testCase)

            state = openmebius.presentation.main ...
                .MainPresentationState();

            unloaded = openmebius.presentation.main.MainUIPolicy ...
                .evaluate(struct("HasProject", false), state);
            loaded = openmebius.presentation.main.MainUIPolicy ...
                .evaluate(struct("HasProject", true), state);

            testCase.verifyFalse(unloaded.DuplicateProjectEnabled);
            testCase.verifyTrue(loaded.DuplicateProjectEnabled);

        end

        function duplicateProjectIsDisabledWhileBusy(testCase)

            state = openmebius.presentation.main ...
                .MainPresentationState();
            state.beginBusy();

            ui = openmebius.presentation.main.MainUIPolicy ...
                .evaluate(struct("HasProject", true), state);

            testCase.verifyFalse(ui.DuplicateProjectEnabled);

        end

    end

end
