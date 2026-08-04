classdef ModelOperationViewModel
    % MODELOPERATIONVIEWMODEL UI values for model-area commands.

    properties (SetAccess = private)
        SectionStatus (1, 1) string
        CompletionStatus (1, 1) string
        Result = []
        Notifications (:, 1) cell
        CompletionNotification = []
        ErrorTitle (1, 1) string
        ValidationReports (:, 1) cell
        ValidationStyles struct
        FinishEditCommit (1, 1) logical
        EditCommitSucceeded (1, 1) logical
    end

    methods

        function obj = ModelOperationViewModel(options)

            arguments
                options.SectionStatus (1, 1) string {mustBeMember( ...
                                                         options.SectionStatus, ["", "running", "error"])} = ""
                options.CompletionStatus (1, 1) string {mustBeMember( ...
                                                            options.CompletionStatus, ["", "finished"])} = ""
                options.Result = []
                options.Notifications (:, 1) cell = cell(0, 1)
                options.CompletionNotification = []
                options.ErrorTitle (1, 1) string = "Model operation failed"
                options.ValidationReports (:, 1) cell = cell(0, 1)
                options.ValidationStyles struct = struct( ...
                    "Target", {}, "Rows", {})
                options.FinishEditCommit (1, 1) logical = false
                options.EditCommitSucceeded (1, 1) logical = false
            end

            obj.SectionStatus = options.SectionStatus;
            obj.CompletionStatus = options.CompletionStatus;
            obj.Result = options.Result;
            obj.Notifications = options.Notifications;
            obj.CompletionNotification = options.CompletionNotification;
            obj.ErrorTitle = options.ErrorTitle;
            obj.ValidationReports = options.ValidationReports;
            obj.ValidationStyles = options.ValidationStyles;
            obj.FinishEditCommit = options.FinishEditCommit;
            obj.EditCommitSucceeded = options.EditCommitSucceeded;

        end % constructor

    end % methods

end % classdef
