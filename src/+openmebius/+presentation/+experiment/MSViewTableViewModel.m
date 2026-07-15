classdef MSViewTableViewModel
    % MSVIEWTABLEVIEWMODEL Immutable table presentation for MSView.

    properties (SetAccess = private)
        Data table
        ExperimentSelectionEnabled (1, 1) logical
        UseHeatmap (1, 1) logical
        ErrorColumns (1, :) logical
        ErrorMask logical
    end

    methods

        function obj = MSViewTableViewModel(options)

            arguments
                options.Data table = table()
                options.ExperimentSelectionEnabled (1, 1) logical = true
                options.UseHeatmap (1, 1) logical = false
                options.ErrorColumns (1, :) logical = false(1, 0)
                options.ErrorMask logical = false(0, 0)
            end

            if ~isempty(options.ErrorColumns) && ...
                    numel(options.ErrorColumns) ~= width(options.Data)
                error( ...
                    "OpenMebius2:MSViewTableViewModel:InvalidErrorColumns", ...
                    "ErrorColumns must contain one value per table column.");
            end

            if ~isempty(options.ErrorMask) && ...
                    ~isequal(size(options.ErrorMask), size(options.Data))
                error( ...
                    "OpenMebius2:MSViewTableViewModel:InvalidErrorMask", ...
                    "ErrorMask must have the same dimensions as Data.");
            end

            obj.Data = options.Data;
            obj.ExperimentSelectionEnabled = ...
                options.ExperimentSelectionEnabled;
            obj.UseHeatmap = options.UseHeatmap;
            obj.ErrorColumns = options.ErrorColumns;
            obj.ErrorMask = options.ErrorMask;

        end % constructor

    end % methods

end % classdef
