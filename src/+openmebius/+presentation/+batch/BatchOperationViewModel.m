classdef BatchOperationViewModel
    % BATCHOPERATIONVIEWMODEL UI values for batch-management commands.

    properties (SetAccess = private)
        TableViewModel = []
        Notifications (:, 1) cell
        ErrorTitle (1, 1) string
    end

    methods

        function obj = BatchOperationViewModel(options)

            arguments
                options.TableViewModel = []
                options.Notifications (:, 1) cell = cell(0, 1)
                options.ErrorTitle (1, 1) string = ...
                    "Batch operation failed"
            end

            obj.TableViewModel = options.TableViewModel;
            obj.Notifications = options.Notifications;
            obj.ErrorTitle = options.ErrorTitle;

        end % constructor

    end % methods

end % classdef
