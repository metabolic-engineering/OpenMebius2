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

        end % method beginBusy

        function beginRun(obj)

            if obj.Activity ~= openmebius.presentation.main.MainActivity.Idle
                error("OpenMebius2:Presentation:InvalidTransition", ...
                    "Another activity is already in progress.")
            end

            if obj.EditTarget ~= openmebius.presentation.main.EditTarget.None
                error("OpenMebius2:Presentation:InvalidTransition", ...
                    "Cannot run while a table is being edited.")
            end

            obj.Activity = openmebius.presentation.main.MainActivity.Running;

        end % method beginRun

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

        end % method beginEdit

        function beginModal(obj)

            import openmebius.presentation.main.MainActivity
            import openmebius.presentation.main.EditTarget

            if obj.Activity ~= MainActivity.Idle
                error( ...
                    "OpenMebius2:Presentation:InvalidTransition", ...
                    "Another activity is already in progress.");
            end

            if obj.EditTarget ~= EditTarget.None
                error( ...
                    "OpenMebius2:Presentation:InvalidTransition", ...
                    "Cannot open modal window while a table is being edited.");
            end

            obj.Activity = MainActivity.Modal;

        end % method beginModal

        function beginEditCommit(obj)

            import openmebius.presentation.main.MainActivity
            import openmebius.presentation.main.EditTarget

            if obj.Activity ~= MainActivity.Idle
                error( ...
                    "OpenMebius2:Presentation:InvalidTransition", ...
                    "Another activity is already in progress.");
            end

            if obj.EditTarget == EditTarget.None
                error( ...
                    "OpenMebius2:Presentation:InvalidTransition", ...
                    "No edit operation is in progress.");
            end

            obj.Activity = MainActivity.Busy;

        end % method beginEditCommit

        function requestCancelRun(obj)

            import openmebius.presentation.main.MainActivity

            if obj.Activity ~= MainActivity.Running
                return
            end

            obj.Activity = MainActivity.Canceling;

        end % method requestCancelRun

        function finishActivity(obj)

            obj.Activity = openmebius.presentation.main.MainActivity.Idle;

        end % method finishActivity

        function finishEdit(obj)

            obj.EditTarget = openmebius.presentation.main.EditTarget.None;

        end % method finishEdit

        function finishRun(obj)

            import openmebius.presentation.main.MainActivity

            if obj.Activity == MainActivity.Canceling || ...
                    obj.Activity == MainActivity.Running

                obj.Activity = MainActivity.Idle;

            end

        end % method finishRun

        function finishModal(obj)

            import openmebius.presentation.main.MainActivity

            if obj.Activity == MainActivity.Modal
                obj.Activity = MainActivity.Idle;
            end

        end % method finishModal

        function setResultMode(obj, mode)

            arguments
                obj (1, 1) openmebius.presentation.main.MainPresentationState
                mode (1, 1) string {mustBeMember(mode, [ ...
                    "overview", "mdv", "mdv-summary", ...
                    "details", "comparison"])}
            end

            obj.ResultMode = mode;

        end % method setResultMode

        function reset(obj)

            obj.Activity = openmebius.presentation.main.MainActivity.Idle;
            obj.EditTarget = openmebius.presentation.main.EditTarget.None;
            obj.ResultMode = "overview";

        end % method reset

    end % methods

end % classdef
