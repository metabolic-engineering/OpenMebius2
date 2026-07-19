classdef ComparisonViewPresenter < handle
    % COMPARISONVIEWPRESENTER Maps experiment comparisons to UI values.

    properties (Access = private)
        Experiments
        Service
    end

    methods

        function obj = ComparisonViewPresenter(experiments, options)

            arguments
                experiments
                options.Service = openmebius.application.experiment ...
                    .ExperimentComparisonService()
            end

            if isempty(experiments) || ...
                    (isa(experiments, "handle") && ~isvalid(experiments))
                error( ...
                    "OpenMebius2:ComparisonView:InvalidExperiments", ...
                    "Experiment data must be a valid object.");
            end

            obj.Experiments = experiments;
            obj.Service = options.Service;

        end % constructor

        function viewModel = presentCatalog(obj)

            try
                catalog = obj.Service.loadCatalog(obj.Experiments);
                viewModel = openmebius.presentation.experiment ...
                    .ComparisonCatalogViewModel( ...
                        IsAvailable = true, ...
                        ExperimentItems = catalog.ExperimentNames, ...
                        DataItems = catalog.DataNames);
            catch exception
                viewModel = openmebius.presentation.experiment ...
                    .ComparisonCatalogViewModel( ...
                        Notifications = { ...
                            obj.notificationFromException(exception)});
            end

        end % presentCatalog

        function viewModel = presentSelection( ...
                obj, experimentNames, dataNames)

            try
                selection = obj.Service.loadSelection( ...
                    obj.Experiments, experimentNames, dataNames);
                numberOfData = numel(selection.DataNames);
                values = cell(numberOfData, 1);
                stackLabels = cell(numberOfData, 1);

                for dataIndex = 1:numberOfData
                    data = selection.Tables{dataIndex};
                    values{dataIndex} = data{:, :}.';
                    stackLabels{dataIndex} = ...
                        string(data.Properties.RowNames).';
                end

                viewModel = openmebius.presentation.experiment ...
                    .ComparisonPlotViewModel( ...
                        IsAvailable = true, ...
                        ExperimentNames = selection.ExperimentNames, ...
                        DataNames = selection.DataNames, ...
                        Values = values, ...
                        StackLabels = stackLabels);
            catch exception
                viewModel = openmebius.presentation.experiment ...
                    .ComparisonPlotViewModel( ...
                        Notifications = { ...
                            obj.notificationFromException(exception)});
            end

        end % presentSelection

    end % methods

    methods (Access = private)

        function notification = notificationFromException(~, exception)

            identifier = string(exception.identifier);
            title = "Comparison data unavailable";

            if startsWith(identifier, ...
                    "OpenMebius2:ExperimentComparison:")
                notification = openmebius.presentation.notification ...
                    .Notification.warning( ...
                        string(exception.message), ...
                        Title = title);
                return
            end

            notification = openmebius.presentation.notification ...
                .Notification.error( ...
                    string(exception.message), ...
                    Title = "Comparison view failed", ...
                    ShowAlert = true);

        end % notificationFromException

    end % methods (Access = private)

end % classdef
