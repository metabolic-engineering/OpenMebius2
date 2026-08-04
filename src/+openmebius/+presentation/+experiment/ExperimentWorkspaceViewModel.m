classdef ExperimentWorkspaceViewModel
    % EXPERIMENTWORKSPACEVIEWMODEL Experiment-area table display state.

    properties (SetAccess = private)
        InformationTable openmebius.presentation.WorkspaceTableViewModel
        TracerTable openmebius.presentation.WorkspaceTableViewModel
        UptakeTable openmebius.presentation.WorkspaceTableViewModel
    end

    methods

        function obj = ExperimentWorkspaceViewModel(options)

            arguments
                options.InformationTable (1, 1) ...
                    openmebius.presentation.WorkspaceTableViewModel = ...
                    openmebius.presentation.WorkspaceTableViewModel()
                options.TracerTable (1, 1) openmebius.presentation ...
                    .WorkspaceTableViewModel = ...
                    openmebius.presentation.WorkspaceTableViewModel()
                options.UptakeTable (1, 1) openmebius.presentation ...
                    .WorkspaceTableViewModel = ...
                    openmebius.presentation.WorkspaceTableViewModel()
            end

            obj.InformationTable = options.InformationTable;
            obj.TracerTable = options.TracerTable;
            obj.UptakeTable = options.UptakeTable;

        end % constructor

    end % methods

end % classdef
