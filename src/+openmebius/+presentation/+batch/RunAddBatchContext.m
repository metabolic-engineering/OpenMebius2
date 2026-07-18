classdef RunAddBatchContext
    % RUNADDBATCHCONTEXT Initial editor state passed to RunAddBatch.

    properties (SetAccess = private)
        Editor openmebius.presentation.batch ...
            .BatchExperimentSelectionEditorViewModel
    end

    methods

        function obj = RunAddBatchContext(options)

            arguments
                options.Editor (1, 1) openmebius.presentation.batch ...
                    .BatchExperimentSelectionEditorViewModel
            end

            if ~options.Editor.IsAvailable
                error( ...
                    "OpenMebius2:RunAddBatchContext:UnavailableEditor", ...
                    "RunAddBatch requires an available editor view model.");
            end

            obj.Editor = options.Editor;

        end % constructor

    end % methods

end % classdef
