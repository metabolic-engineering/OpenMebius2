classdef RunAddBatchAction
    % RUNADDBATCHACTION Maps child-app input to a typed selection.

    properties (SetAccess = private)
        Editor openmebius.presentation.batch ...
            .BatchExperimentSelectionEditorViewModel
    end

    methods

        function obj = RunAddBatchAction(editor)

            arguments
                editor (1, 1) openmebius.presentation.batch ...
                    .BatchExperimentSelectionEditorViewModel
            end

            obj.Editor = editor;

        end % constructor

        function data = initialTable(obj)

            names = obj.Editor.ExperimentNames;
            data = table( ...
                false(numel(names), 1), ...
                names, ...
                VariableNames = ["Add", "Experiment"]);

        end % initialTable

        function selection = createSelection(obj, data, addAsParallel)

            arguments
                obj (1, 1) openmebius.presentation.batch.RunAddBatchAction
                data table
                addAsParallel (1, 1) logical
            end

            selectedExperiments = string(data{logical(data{:, 1}), 2});

            if isempty(selectedExperiments)
                selection = [];
                return
            end

            selection = openmebius.domain.batch ...
                .BatchExperimentSelection( ...
                Mode = obj.Editor.Mode, ...
                Experiments = selectedExperiments, ...
                AddAsParallel = addAsParallel, ...
                BatchId = obj.Editor.BatchId);

        end % createSelection

    end % methods

end % classdef
