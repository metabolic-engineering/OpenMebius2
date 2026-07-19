classdef MainApplicationSessionTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function ownsAndReplacesWorkspaceObjects(testCase)

            session = openmebius.application.session ...
                .MainApplicationSession();
            project = MainApplicationSessionTest.projectSession();
            result = helpers.SessionResultStub();

            session.replaceProject( ...
                project, "model", "experiments", "batch", result);

            testCase.verifySameHandle(session.Project, project);
            testCase.verifyEqual(session.Model, "model");
            testCase.verifyEqual(session.Experiments, "experiments");
            testCase.verifyEqual(session.Batch, "batch");
            testCase.verifySameHandle(session.Result, result);

            session.replaceModel("updated-model");
            session.replaceExperimentState( ...
                "updated-experiments", "updated-batch");

            testCase.verifyEqual(session.Model, "updated-model");
            testCase.verifyEqual( ...
                session.Experiments, "updated-experiments");
            testCase.verifyEqual(session.Batch, "updated-batch");

        end

        function forwardsResultNotifications(testCase)

            session = openmebius.application.session ...
                .MainApplicationSession();
            result = helpers.SessionResultStub();
            received = strings(0, 1);

            session.setNotificationReporter(@recordNotification);
            session.replaceArtifacts([], [], [], result);
            result.report("message");

            replacement = helpers.SessionResultStub();
            session.replaceArtifacts([], [], [], replacement);
            result.report("stale-message");
            replacement.report("replacement-message");

            testCase.verifyEqual( ...
                received, ["message"; "replacement-message"]);

            function recordNotification(notification)
                received(end + 1, 1) = string(notification);
            end

        end

    end

    methods (Static, Access = private)

        function project = projectSession()

            metadata = openmebius.domain.project.ProjectMetadata( ...
                Name = "project", Author = "author", Organism = "test");
            paths = openmebius.domain.project.ProjectPaths( ...
                string(tempdir));
            project = openmebius.domain.project.ProjectSession( ...
                metadata, paths);

        end

    end

end
