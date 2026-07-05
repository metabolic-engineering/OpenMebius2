classdef MainPresenter < handle

    properties (Access = private)
        State openmebius.presentation.main.MainPresentationState
    end

    methods

        function obj = MainPresenter()
            obj.State = ...
                openmebius.presentation.main.MainPresentationState();
        end

        function viewModel = initialize(obj, context)
            obj.State.reset();
            viewModel = obj.present(context);
        end

        function viewModel = reset(obj, context)
            obj.State.reset();
            viewModel = obj.present(context);
        end

        function viewModel = refresh(obj, context)
            viewModel = obj.present(context);
        end

        function viewModel = beginOperation(obj, context)
            % BEGINOPERATION
            % For general non-edit operations:
            %   Project Load
            %   Template Model Load
            %   Experiment Import
            %   Result Reload
            %
            % Do not use this for Model/MS Save while editing.
            obj.State.beginBusy();
            viewModel = obj.present(context);
        end

        function viewModel = finishOperation(obj, context)
            obj.State.finishActivity();
            viewModel = obj.present(context);
        end

        function viewModel = beginRun(obj, context)
            obj.State.beginRun();
            viewModel = obj.present(context);
        end

        function viewModel = finishRun(obj, context)
            obj.State.finishActivity();
            viewModel = obj.present(context);
        end

        function tf = isRunning(obj)

            import openmebius.presentation.main.MainActivity

            tf = obj.State.Activity == MainActivity.Running || ...
                obj.State.Activity == MainActivity.Cancelling;

        end

        function tf = isCancelling(obj)

            import openmebius.presentation.main.MainActivity

            tf = obj.State.Activity == MainActivity.Cancelling;

        end

        function viewModel = beginEdit(obj, target, context)

            arguments
                obj
                target openmebius.presentation.main.EditTarget
                context struct
            end

            obj.State.beginEdit(target);
            viewModel = obj.present(context);
        end

        function viewModel = finishEdit(obj, context)
            obj.State.finishEdit();
            viewModel = obj.present(context);
        end

        function viewModel = beginEditCommit(obj, context)
            % BEGINEDITCOMMIT
            % Starts a short busy operation while preserving EditTarget.
            %
            % State transition:
            %   Activity   Idle  -> Busy
            %   EditTarget Model -> Model
            %
            % This is used by:
            %   ModelSaveButtonPushed
            %   MSSaveButtonPushed

            obj.State.beginBusy();
            viewModel = obj.present(context);

        end

        function viewModel = finishEditCommit(obj, context, success)
            % FINISHEDITCOMMIT
            % Ends a short busy operation while preserving or clearing EditTarget.
            %
            % State transition:
            %   Activity   Busy -> Idle
            %   EditTarget Model -> None (if success)

            arguments
                obj
                context struct
                success (1, 1) logical
            end

            obj.State.finishActivity();

            if success
                obj.State.finishEdit();
            end

            viewModel = obj.present(context);

        end

        function viewModel = failEditCommit(obj, context)
            % FAILEDITCOMMIT
            % Convenience wrapper for failed edit commit.
            %
            % Activity is returned to Idle, but EditTarget is preserved.

            viewModel = obj.finishEditCommit(context, false);

        end

        function viewModel = succeedEditCommit(obj, context)
            % SUCCEEDEDITCOMMIT
            % Convenience wrapper for successful edit commit.
            %
            % Activity is returned to Idle, and EditTarget is cleared.

            viewModel = obj.finishEditCommit(context, true);

        end

        function viewModel = requestCancelRun(obj, context)

            obj.State.requestCancelRun();
            viewModel = obj.present(context);

        end

        function viewModel = setResultMode(obj, mode, context)
            obj.State.setResultMode(mode);
            viewModel = obj.present(context);
        end

        function viewModel = forceIdle(obj, context)
            % FORCEIDLE
            % Development / recovery utility.
            % Do not use this as the normal way to leave operations.

            obj.State.finishActivity();
            viewModel = obj.present(context);

        end

    end

    methods (Access = private)

        function viewModel = present(obj, context)

            uiState = ...
                openmebius.presentation.main.MainUIPolicy.evaluate( ...
                context, obj.State);

            viewModel = ...
                openmebius.presentation.main.MainViewModel(uiState);
        end

    end

end
