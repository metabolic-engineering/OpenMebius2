classdef MainApplicationSession < handle
    % MAINAPPLICATIONSESSION Owns the mutable workspace used by the app.

    properties (SetAccess = private)
        Project = []
        Model = []
        Experiments = []
        Batch = []
        Result = []
    end

    properties (Access = private)
        NotificationReporter (1, 1) function_handle = @(~) []
    end

    methods

        function setNotificationReporter(obj, reporter)

            arguments
                obj (1, 1) openmebius.application.session ...
                    .MainApplicationSession
                reporter (1, 1) function_handle
            end

            obj.NotificationReporter = reporter;
            obj.configureResultReporter(obj.Result, reporter);

        end % setNotificationReporter

        function replaceProject(obj, project, model, experiments, batch, result)

            arguments
                obj (1, 1) openmebius.application.session ...
                    .MainApplicationSession
                project (1, 1) openmebius.domain.project.ProjectSession
                model
                experiments
                batch
                result
            end

            obj.configureResultReporter(obj.Result, @(~) []);
            obj.configureResultReporter(result, obj.NotificationReporter);

            obj.Project = project;
            obj.Model = model;
            obj.Experiments = experiments;
            obj.Batch = batch;
            obj.Result = result;

        end % replaceProject

        function setProject(obj, project)

            arguments
                obj (1, 1) openmebius.application.session ...
                    .MainApplicationSession
                project (1, 1) openmebius.domain.project.ProjectSession
            end

            obj.Project = project;

        end % setProject

        function replaceArtifacts(obj, model, experiments, batch, result)

            obj.configureResultReporter(obj.Result, @(~) []);
            obj.configureResultReporter(result, obj.NotificationReporter);

            obj.Model = model;
            obj.Experiments = experiments;
            obj.Batch = batch;
            obj.Result = result;

        end % replaceArtifacts

        function replaceModel(obj, model)

            obj.Model = model;

        end % replaceModel

        function replaceExperimentState(obj, experiments, batch)

            obj.Experiments = experiments;
            obj.Batch = batch;

        end % replaceExperimentState

        function clear(obj)

            obj.configureResultReporter(obj.Result, @(~) []);

            obj.Project = [];
            obj.Model = [];
            obj.Experiments = [];
            obj.Batch = [];
            obj.Result = [];

        end % clear

    end % methods

    methods (Access = private)

        function configureResultReporter(~, result, reporter)

            if isempty(result)
                return
            end

            if isobject(result) && ismethod(result, "setNotificationReporter")
                result.setNotificationReporter(reporter);
            end

        end % configureResultReporter

    end % methods (Access = private)

end % classdef
