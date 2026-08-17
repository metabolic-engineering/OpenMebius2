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

        function modelContextMenuIsAvailableOnlyWhileEditingModel(testCase)

            import openmebius.presentation.main.EditTarget

            state = openmebius.presentation.main.MainPresentationState();
            context = struct("HasModel", true);
            idle = openmebius.presentation.main.MainUIPolicy ...
                .evaluate(context, state);

            state.beginEdit(EditTarget.Model);
            editing = openmebius.presentation.main.MainUIPolicy ...
                .evaluate(context, state);

            testCase.verifyFalse(idle.ModelContextMenuEnabled);
            testCase.verifyTrue(editing.ModelContextMenuEnabled);

        end

        function tracerPatternTableIsAlwaysReadOnly(testCase)

            state = openmebius.presentation.main ...
                .MainPresentationState();
            ui = openmebius.presentation.main.MainUIPolicy ...
                .evaluate(struct("HasExperiments", true), state);

            testCase.verifyFalse(ui.TracerTableEditable);
            testCase.verifyTrue(ui.UptakeTableEditable);

            state.beginBusy();
            busy = openmebius.presentation.main.MainUIPolicy ...
                .evaluate(struct("HasExperiments", true), state);
            testCase.verifyFalse(busy.TracerTableEditable);
            testCase.verifyFalse(busy.UptakeTableEditable);

        end

    end

end
