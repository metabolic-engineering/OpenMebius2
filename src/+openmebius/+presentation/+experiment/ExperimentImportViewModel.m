classdef ExperimentImportViewModel
    % EXPERIMENTIMPORTVIEWMODEL UI values for experiment import state.

    properties (SetAccess = private)
        SectionStatus (1, 1) string
        Result
        Notifications (:, 1) cell
    end

    methods

        function obj = ExperimentImportViewModel(options)

            arguments
                options.SectionStatus (1, 1) string {mustBeMember( ...
                                                         options.SectionStatus, ...
                                                         ["", "running", "finished", "error"])} = ""
                options.Result = []
                options.Notifications (:, 1) cell = cell(0, 1)
            end

            obj.SectionStatus = options.SectionStatus;
            obj.Result = options.Result;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
