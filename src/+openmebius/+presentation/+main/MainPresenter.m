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

        function viewModel = refresh(obj, context)
            viewModel = obj.present(context);
        end

        function viewModel = beginOperation(obj, context)
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

        function viewModel = setResultMode(obj, mode, context)
            obj.State.setResultMode(mode);
            viewModel = obj.present(context);
        end

    end

    methods (Access = private)

        function viewModel = present(obj, context)

            uiState = ...
                openmebius.presentation.main.MainUiPolicy.evaluate( ...
                context, obj.State);

            viewModel = ...
                openmebius.presentation.main.MainViewModel(uiState);
        end

    end

end
