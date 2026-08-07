classdef PreferencesIntegrationTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addPaths(~)

            root = PreferencesIntegrationTest.repositoryRoot();
            addpath(fullfile(root, "src"));
            addpath(fullfile(root, "tests"));

        end

    end

    methods (Test)

        function closeButtonSavesAndNotifiesParent(testCase)

            directory = string(tempname);
            mkdir(directory);
            directoryCleanup = onCleanup( ...
                @() rmdir(directory, "s"));
            preference = openmebius.infrastructure.preferences ...
                .MDVCorrectionPreference( ...
                StorageDirectory = directory);
            app = Preferences( ...
                helpers.SlackWebhookNotifierStub(), ...
                @(~) [], ...
                preference);
            appCleanup = onCleanup(@() deleteIfValid(app));
            presenter = openmebius.presentation.main.MainPresenter();
            lockedViewModel = presenter.beginPreferences(struct());
            testCase.verifyFalse( ...
                lockedViewModel.UiState.MainInteractionEnabled);
            childAppHost = openmebius.presentation.lifecycle.ChildAppHost();
            hostCleanup = onCleanup(@() delete(childAppHost));
            notificationCount = 0;
            unlockedViewModel = [];
            childAppHost.attach( ...
                "Preferences", ...
                app, ...
                {"PreferencesClosed", @recordNotification});

            testCase.verifyTrue(any(strcmp( ...
                app.MDVcorrectionDropDown.ItemsData, ...
            "least-squares-with-fraction")));
            app.MDVcorrectionDropDown.Value = ...
                "least-squares-with-fraction";
            closeCallback = app.CloseButton.ButtonPushedFcn;
            closeCallback(app.CloseButton, []);

            testCase.verifyEqual(notificationCount, 1);
            testCase.verifyFalse(isvalid(app));
            testCase.verifyFalse( ...
                childAppHost.isAttached("Preferences"));
            testCase.verifyTrue( ...
                unlockedViewModel.UiState.MainInteractionEnabled);
            testCase.verifyEqual( ...
                preference.getMethod(), ...
            "least-squares-with-fraction");

            function recordNotification(~, ~)

                notificationCount = notificationCount + 1;
                childAppHost.detach("Preferences");
                unlockedViewModel = presenter.finishPreferences(struct());

            end

        end

    end

    methods (Static, Access = private)

        function root = repositoryRoot()

            root = fileparts(fileparts(mfilename("fullpath")));

        end

    end

end % classdef

function deleteIfValid(app)

    try

        if isvalid(app)
            delete(app);
        end

    catch
    end

end
