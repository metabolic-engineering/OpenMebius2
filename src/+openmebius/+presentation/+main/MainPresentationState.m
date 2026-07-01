classdef MainPresentationState < handle

    properties (SetAccess = private)

        Activity openmebius.presentation.main.MainActivity = ...
            openmebius.presentation.main.MainActivity.Idle

        EditTarget openmebius.presentation.main.EditTarget = ...
            openmebius.presentation.main.EditTarget.None

        ResultMode (1, 1) string = "overview"

    end

    methods

        function beginBusy(obj)

            if obj.Activity == openmebius.presentation.main.MainActivity.Busy
                error("OpenMebius2:Presentation:InvalidTransition", ...
                "Another activity is already in progress.")
            end

            if obj.Activity == openmebius.presentation.main.MainActivity.Running
                error( ...
                    "OpenMebius2:Presentation:AnalysisAlreadyRunning", ...
                "Analysis is already running.");
            end

            obj.Activity = openmebius.presentation.main.MainActivity.Busy;

        end

        function beginRun(obj)

            if obj.Activity ~= openmebius.presentation.main.MainActivity.Idle
                error("OpenMebius2:Presentation:InvalidTransition", ...
                "Another activity is already in progress.")
            end

            if obj.EditTarget ~= openmebius.presentation.main.EditTarget.None
                error("OpenMebius2:Presentation:InvalidTransition", ...
                "Cannot run while a table is being edited.")
            end

            obj.Activity = openmebius.presentation.main.MainActivity.Run;

        end

        function beginEdit(obj, target)

            if obj.Activity ~= openmebius.presentation.main.MainActivity.Idle
                error("OpenMebius2:Presentation:InvalidTransition", ...
                "Another activity is already in progress.")
            end

            if obj.EditTarget ~= openmebius.presentation.main.EditTarget.None
                error("OpenMebius2:Presentation:InvalidTransition", ...
                "Cannot edit while another table is being edited.")
            end

            obj.EditTarget = target;

        end

        function finishActivity(obj)

            obj.Activity = openmebius.presentation.main.MainActivity.Idle;

        end

        function finishEdit(obj)

            obj.EditTarget = openmebius.presentation.main.EditTarget.None;

        end

        function setResultMode(obj, mode)

            arguments
                obj (1, 1) openmebius.presentation.main.MainPresentationState
                mode (1, 1) string {mustBeMember(mode, ["overview", "details", "comparison"])}
            end

            obj.ResultMode = mode;

        end

        function reset(obj)

            obj.Activity = openmebius.presentation.main.MainActivity.Idle;
            obj.EditTarget = openmebius.presentation.main.EditTarget.None;
            obj.ResultMode = "overview";

        end

    end

end
