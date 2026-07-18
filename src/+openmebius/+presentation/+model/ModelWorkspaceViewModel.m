classdef ModelWorkspaceViewModel
    % MODELWORKSPACEVIEWMODEL Model-area table display state.

    properties (SetAccess = private)
        ModelTable openmebius.presentation.WorkspaceTableViewModel
        MassSpectrometryTable openmebius.presentation.WorkspaceTableViewModel
        AtomTable openmebius.presentation.WorkspaceTableViewModel
        BiomassTable openmebius.presentation.WorkspaceTableViewModel
    end

    methods

        function obj = ModelWorkspaceViewModel(options)

            arguments
                options.ModelTable (1, 1) openmebius.presentation ...
                    .WorkspaceTableViewModel = ...
                    openmebius.presentation.WorkspaceTableViewModel()
                options.MassSpectrometryTable (1, 1) ...
                    openmebius.presentation.WorkspaceTableViewModel = ...
                    openmebius.presentation.WorkspaceTableViewModel()
                options.AtomTable (1, 1) openmebius.presentation ...
                    .WorkspaceTableViewModel = ...
                    openmebius.presentation.WorkspaceTableViewModel()
                options.BiomassTable (1, 1) openmebius.presentation ...
                    .WorkspaceTableViewModel = ...
                    openmebius.presentation.WorkspaceTableViewModel()
            end

            obj.ModelTable = options.ModelTable;
            obj.MassSpectrometryTable = ...
                options.MassSpectrometryTable;
            obj.AtomTable = options.AtomTable;
            obj.BiomassTable = options.BiomassTable;

        end % constructor

    end % methods

end % classdef
