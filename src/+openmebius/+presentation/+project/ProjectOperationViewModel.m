classdef ProjectOperationViewModel
    % PROJECTOPERATIONVIEWMODEL UI values for project-area commands.

    properties (SetAccess = private)
        ModelStatus (1, 1) string
        ArtifactMode (1, 1) string
        Session = []
        Artifacts = []
        Notifications (:, 1) cell
    end

    methods

        function obj = ProjectOperationViewModel(options)

            arguments
                options.ModelStatus (1, 1) string {mustBeMember( ...
                    options.ModelStatus, ["", "running", "error"])} = ""
                options.ArtifactMode (1, 1) string {mustBeMember( ...
                    options.ArtifactMode, ["", "open", "create"])} = ""
                options.Session = []
                options.Artifacts = []
                options.Notifications (:, 1) cell = cell(0, 1)
            end

            obj.ModelStatus = options.ModelStatus;
            obj.ArtifactMode = options.ArtifactMode;
            obj.Session = options.Session;
            obj.Artifacts = options.Artifacts;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
