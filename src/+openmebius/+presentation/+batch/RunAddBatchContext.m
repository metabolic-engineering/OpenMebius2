classdef RunAddBatchContext
    % RUNADDBATCHCONTEXT Initial editor state passed to RunAddBatch.

    properties (SetAccess = private)
        Editor openmebius.presentation.batch ...
            .BatchExperimentSelectionEditorViewModel
        Action openmebius.presentation.batch.RunAddBatchAction
    end

    methods

        function obj = RunAddBatchContext(options)

            arguments
                options.Editor (1, 1) openmebius.presentation.batch ...
                    .BatchExperimentSelectionEditorViewModel
                options.Action = []
            end

            if ~options.Editor.IsAvailable
                error( ...
                    "OpenMebius2:RunAddBatchContext:UnavailableEditor", ...
                    "RunAddBatch requires an available editor view model.");
            end

            obj.Editor = options.Editor;

            if isempty(options.Action)
                obj.Action = openmebius.presentation.batch ...
                    .RunAddBatchAction(options.Editor);
            else
                obj.Action = options.Action;
            end

        end % constructor

    end % methods

end % classdef
