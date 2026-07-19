classdef BatchRunViewModel
    % BATCHRUNVIEWMODEL Presentation values for a complete batch run.

    properties (SetAccess = private)
        SectionStatus (1, 1) string
        Notification
        CompletionStatus (1, 1) string
        ElapsedTime (1, 1) duration
        ErrorMessage (1, 1) string
    end

    methods

        function obj = BatchRunViewModel(options)

            arguments
                options.SectionStatus (1, 1) string {mustBeMember( ...
                    options.SectionStatus, ...
                    ["", "running", "finished", "error"])} = ""
                options.Notification = []
                options.CompletionStatus (1, 1) string {mustBeMember( ...
                    options.CompletionStatus, ...
                    ["", "finished", "canceled", "error"])} = ""
                options.ElapsedTime (1, 1) duration = seconds(0)
                options.ErrorMessage (1, 1) string = ""
            end

            obj.SectionStatus = options.SectionStatus;
            obj.Notification = options.Notification;
            obj.CompletionStatus = options.CompletionStatus;
            obj.ElapsedTime = options.ElapsedTime;
            obj.ErrorMessage = options.ErrorMessage;

        end % constructor

    end % methods

end % classdef
