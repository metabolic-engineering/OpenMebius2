classdef MainPresenter < handle

    properties (SetAccess = private)
        Session openmebius.application.ApplicationSession
    end

    properties (Access = private)
        UseCases
        State openmebius.presentation.main.MainPresentationState
        ViewModelFactory openmebius.presentation.main.MainViewModelFactory
        ExceptionMapper
        RunListeners event.listener = event.listener.empty(0, 1)
    end

    events
        ViewChanged
        ProgressChanged
        NotificationRaised
    end

    methods

        function obj = MainPresenter( ...
                session, useCases, viewModelFactory, exceptionMapper)

            obj.Session = session;
            obj.UseCases = useCases;
            obj.ViewModelFactory = viewModelFactory;
            obj.ExceptionMapper = exceptionMapper;
            obj.State = ...
                openmebius.presentation.main.MainPresentationState();
        end

        function result = initialize(obj, startupProjectPath)

            arguments
                obj
                startupProjectPath string = ""
            end

            if startupProjectPath == ""
                result = obj.present();
                return
            end

            result = obj.openProject(startupProjectPath);
        end

        function result = openProject(obj, projectPath)

            arguments
                obj
                projectPath (1, 1) string
            end

            try
                obj.UseCases.OpenProject.execute(projectPath);
                obj.State.resetForProject();

                notification = ...
                    openmebius.presentation.shared.Notification.info( ...
                "Project was loaded successfully.");

                result = obj.present(notification);

            catch ME
                result = obj.presentException(ME);
            end

        end

        function result = saveProject(obj, metadata)

            try
                obj.UseCases.SaveProject.execute(metadata);

                notification = ...
                    openmebius.presentation.shared.Notification.info( ...
                "Project was saved successfully.");

                result = obj.present(notification);

            catch ME
                result = obj.presentException(ME);
            end

        end

        function result = startModelEdit(obj)
            obj.State.IsModelEditing = true;
            result = obj.present();
        end

        function result = cancelModelEdit(obj)
            obj.State.IsModelEditing = false;
            result = obj.present();
        end

        function result = applyModelEdits(obj, command)

            try
                obj.UseCases.UpdateModel.execute(command);
                obj.State.IsModelEditing = false;

                result = obj.present( ...
                    openmebius.presentation.shared.Notification.info( ...
                "Model was updated."));
            catch ME
                result = obj.presentException(ME);
            end

        end

        function result = setResultMode(obj, mode)
            obj.State.ResultMode = mode;
            result = obj.present();
        end

        function result = selectResultBatch(obj, batchIds)
            obj.State.SelectedBatchIds = batchIds;

            try
                projection = ...
                    obj.UseCases.QueryResult.execute(batchIds);

                obj.State.ResultProjection = projection;
                result = obj.present();
            catch ME
                result = obj.presentException(ME);
            end

        end

        function runBatches(obj, batchIds)

            try
                runHandle = obj.UseCases.RunBatch.start(batchIds);
                obj.attachRunListeners(runHandle);
                obj.publishView();
            catch ME
                obj.publishException(ME);
            end

        end

        function cancelRun(obj)
            obj.UseCases.CancelBatch.execute();
        end

        function vm = getCurrentViewModel(obj)
            vm = obj.ViewModelFactory.create(obj.Session, obj.State);
        end

    end

    methods (Access = private)

        function result = present(obj, notifications)

            arguments
                obj
                notifications = ...
                    openmebius.presentation.shared.Notification.empty()
            end

            vm = obj.getCurrentViewModel();

            result = ...
                openmebius.presentation.main.MainPresentationResult( ...
                ViewModel = vm, ...
                Notifications = notifications);
        end

        function result = presentException(obj, exception)
            notification = obj.ExceptionMapper.map(exception);
            result = obj.present(notification);
        end

        function publishView(obj)
            eventData = ...
                openmebius.presentation.main.MainViewChangedEventData( ...
                obj.getCurrentViewModel());

            notify(obj, "ViewChanged", eventData);
        end

        function publishException(obj, exception)
            notification = obj.ExceptionMapper.map(exception);

            notify(obj, "NotificationRaised", ...
                openmebius.presentation.main.NotificationEventData( ...
                notification));
        end

        function attachRunListeners(obj, runHandle)
            delete(obj.RunListeners);

            obj.RunListeners(1) = addlistener( ...
                runHandle, "ProgressChanged", ...
                @(~, event) obj.onRunProgress(event));

            obj.RunListeners(2) = addlistener( ...
                runHandle, "Completed", ...
                @(~, event) obj.onRunCompleted(event));

            obj.RunListeners(3) = addlistener( ...
                runHandle, "Failed", ...
                @(~, event) obj.onRunFailed(event));
        end

        function onRunProgress(obj, event)
            notify(obj, "ProgressChanged", ...
                openmebius.presentation.main.ProgressChangedEventData( ...
                event.Progress));
        end

        function onRunCompleted(obj, event)
            obj.UseCases.CompleteBatch.execute(event.Result);
            obj.publishView();
        end

        function onRunFailed(obj, event)
            obj.publishException(event.Exception);
            obj.publishView();
        end

    end

end
