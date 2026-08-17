classdef LabelConfigAction < handle
    % LABELCONFIGACTION Owns the editable state of the label child app.

    properties (SetAccess = private)
        LabelTable table
        RatioTables struct
        FieldNames cell
    end

    properties (Access = private)
        InitialLabelTable table
        InitialRatioTables struct
    end

    methods

        function obj = LabelConfigAction(labelTable, ratioTables)

            arguments
                labelTable table
                ratioTables struct
            end

            obj.InitialLabelTable = labelTable;
            obj.InitialRatioTables = ratioTables;
            obj.restore();

        end % constructor

        function restore(obj)

            obj.LabelTable = obj.InitialLabelTable;
            obj.RatioTables = obj.InitialRatioTables;
            obj.FieldNames = fieldnames(obj.InitialRatioTables);

        end % restore

        function ratioTable = selectLabel(obj, index)

            index = obj.validateLabelIndex(index);
            ratioTable = obj.normalizeRatioTable( ...
                obj.RatioTables.(obj.FieldNames{index}));

        end % selectLabel

        function message = addLabel(obj)

            obj.LabelTable = [obj.LabelTable; {'New label', 1}];
            names = [obj.FieldNames; {'New label'}];
            obj.FieldNames = matlab.lang.makeUniqueStrings( ...
                matlab.lang.makeValidName(names));
            obj.RatioTables.(obj.FieldNames{end}) = table( ...
                Size = [0, 2], ...
                VariableTypes = ["cell", "cell"], ...
                VariableNames = ["Label", "Ratio"]);
            message = "New label added";

        end % addLabel

        function message = removeLabels(obj, indices)

            indices = unique(indices(:));

            if isempty(indices)
                message = "";
                return
            end

            if any(indices < 1) || any(indices > height(obj.LabelTable))
                error( ...
                    "OpenMebius2:LabelConfig:InvalidLabelSelection", ...
                    "The selected label row is outside the table.");
            end

            labels = string(obj.LabelTable{indices, 1});
            fields = obj.FieldNames(indices);
            obj.LabelTable(indices, :) = [];
            obj.RatioTables = rmfield(obj.RatioTables, fields);
            obj.FieldNames(indices) = [];
            message = "Label pattern [" + strjoin(labels, ", ") + ...
                "] removed from the list";

        end % removeLabels

        function [ratioTable, message] = addRatio(obj, labelIndex)

            labelIndex = obj.validateLabelIndex(labelIndex);
            fieldName = obj.FieldNames{labelIndex};
            ratioTable = obj.normalizeRatioTable( ...
                obj.RatioTables.(fieldName));
            ratioTable = [ratioTable; {'pattern', 1}];
            obj.RatioTables.(fieldName) = ratioTable;
            label = string(obj.LabelTable{labelIndex, 1});
            message = "New ratio added to [" + label + "]";

        end % addRatio

        function [ratioTable, message] = removeRatio( ...
                obj, labelIndex, ratioIndex)

            labelIndex = obj.validateLabelIndex(labelIndex);
            fieldName = obj.FieldNames{labelIndex};
            ratioTable = obj.normalizeRatioTable( ...
                obj.RatioTables.(fieldName));

            if ratioIndex < 1 || ratioIndex > height(ratioTable)
                error( ...
                    "OpenMebius2:LabelConfig:InvalidRatioSelection", ...
                    "The selected ratio row is outside the table.");
            end

            ratioTable(ratioIndex, :) = [];
            obj.RatioTables.(fieldName) = ratioTable;
            label = string(obj.LabelTable{labelIndex, 1});
            message = "Ratio pattern removed from [" + label + "]";

        end % removeRatio

        function updateLabelTable(obj, labelTable)

            arguments
                obj (1, 1) openmebius.presentation.model.LabelConfigAction
                labelTable table
            end

            obj.LabelTable = labelTable;

        end % updateLabelTable

        function updateRatioTable(obj, labelIndex, ratioData)

            labelIndex = obj.validateLabelIndex(labelIndex);
            fieldName = obj.FieldNames{labelIndex};
            obj.RatioTables.(fieldName) = ...
                obj.normalizeRatioTable(ratioData);

        end % updateRatioTable

    end % methods

    methods (Access = private)

        function index = validateLabelIndex(obj, index)

            index = double(index);

            if ~isscalar(index) || ~isfinite(index) || ...
                    index ~= fix(index) || index < 1 || ...
                    index > height(obj.LabelTable)
                error( ...
                    "OpenMebius2:LabelConfig:InvalidLabelSelection", ...
                    "Select a valid label row.");
            end

        end % validateLabelIndex

        function ratioTable = normalizeRatioTable(~, ratioData)

            if istable(ratioData)
                ratioTable = ratioData;
                return
            end

            if isempty(ratioData)
                ratioData = cell(0, 2);
            end

            if ~iscell(ratioData) || size(ratioData, 2) ~= 2
                error( ...
                    "OpenMebius2:LabelConfig:InvalidRatioTable", ...
                    "Ratio settings must contain Label and Ratio columns.");
            end

            ratioTable = cell2table( ...
                ratioData, ...
                VariableNames = ["Label", "Ratio"]);

        end % normalizeRatioTable

    end % methods (Access = private)

end % classdef
