classdef ExperimentEditViewModel
    % EXPERIMENTEDITVIEWMODEL UI values for experiment editing state.

    properties (SetAccess = private)
        SectionStatus (1, 1) string
        UpdatedTable table
        Notifications (:, 1) cell
    end

    methods

        function obj = ExperimentEditViewModel(options)

            arguments
                options.SectionStatus (1, 1) string {mustBeMember( ...
                                                         options.SectionStatus, ...
                                                         ["", "running", "finished", "error"])} = ""
                options.UpdatedTable table = table()
                options.Notifications (:, 1) cell = cell(0, 1)
            end

            obj.SectionStatus = options.SectionStatus;
            obj.UpdatedTable = options.UpdatedTable;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
