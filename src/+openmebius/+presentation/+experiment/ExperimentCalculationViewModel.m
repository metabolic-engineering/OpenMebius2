classdef ExperimentCalculationViewModel
    % EXPERIMENTCALCULATIONVIEWMODEL UI values for MDV calculation state.

    properties (SetAccess = private)
        SectionStatus (1, 1) string
        Notifications (:, 1) cell
    end

    methods

        function obj = ExperimentCalculationViewModel(options)

            arguments
                options.SectionStatus (1, 1) string {mustBeMember( ...
                                                         options.SectionStatus, ...
                                                         ["running", "finished", "error"])}
                options.Notifications (:, 1) cell = cell(0, 1)
            end

            obj.SectionStatus = options.SectionStatus;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
