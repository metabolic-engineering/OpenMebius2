classdef ModelPathwayEditViewModel
    % MODELPATHWAYEDITVIEWMODEL Updated table and pathway rendering state.

    properties (SetAccess = private)
        UpdatedModelTable table
        Pathway openmebius.presentation.model.PathwayPlotViewModel
        Notifications (:, 1) cell
    end

    methods

        function obj = ModelPathwayEditViewModel(options)

            arguments
                options.UpdatedModelTable table = table()
                options.Pathway openmebius.presentation.model ...
                    .PathwayPlotViewModel = ...
                    openmebius.presentation.model.PathwayPlotViewModel()
                options.Notifications (:, 1) cell = cell(0, 1)
            end

            obj.UpdatedModelTable = options.UpdatedModelTable;
            obj.Pathway = options.Pathway;
            obj.Notifications = options.Notifications;

        end % constructor

    end % methods

end % classdef
