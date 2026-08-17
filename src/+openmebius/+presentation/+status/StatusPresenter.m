classdef StatusPresenter
    % STATUSPRESENTER
    % Converts application artifact statuses into rows for StatusHTML.
    %
    % This class does not depend on App Designer components.

    methods (Static)

        function statuses = initial()
            statuses = strings(4, 1);
            statuses(:) = "init";
        end

        function [statuses, rows] = update(currentStatuses, section, status)

            import openmebius.presentation.status.StatusPresenter

            section = string(section);
            status = string(status);

            StatusPresenter.mustBeValidSection(section);
            StatusPresenter.mustBeValidStatus(status);

            statuses = ...
                StatusPresenter.normalizeStatuses( ...
                currentStatuses);

            idx = ...
                StatusPresenter.sectionIndex(section);

            statuses(idx) = status;

            rows = ...
                StatusPresenter.rows(statuses);
        end

        function rows = rows(statuses)

            import openmebius.presentation.status.StatusPresenter

            statuses = ...
                StatusPresenter.normalizeStatuses( ...
                statuses);

            sections = ["model"; "experiment"; "batch"; "result"];
            labels = ["Model"; "Experiment"; "Batch"; "Result"];

            rows = cell(1, numel(sections));

            for i = 1:numel(sections)

                [icon, text] = ...
                    StatusPresenter.item(sections(i), statuses(i));

                rows{i} = sprintf( ...
                    '<tr><td>%s</td><td>%s</td><td>%s</td></tr>', ...
                    char(icon), ...
                    char(labels(i)), ...
                    char(text));
            end

        end

        function statuses = normalizeStatuses(currentStatuses)

            if isempty(currentStatuses)
                statuses = ...
                    openmebius.presentation.status.StatusPresenter.initial();
                return
            end

            statuses = string(currentStatuses);
            statuses = statuses(:);

            if numel(statuses) < 4
                tmp = ...
                    openmebius.presentation.status.StatusPresenter.initial();

                tmp(1:numel(statuses)) = statuses;
                statuses = tmp;

            elseif numel(statuses) > 4
                statuses = statuses(1:4);
            end

            allowed = ...
                openmebius.presentation.status.StatusPresenter.allowedStatuses();

            if any(~ismember(statuses, allowed))
                error( ...
                    "OpenMebius2:Status:InvalidStatusVector", ...
                    "Status vector contains unsupported status value.");
            end

        end

        function allowed = allowedStatuses()
            allowed = ["init", "running", "finished", "error"];
        end

        function sections = allowedSections()
            sections = ["model", "experiment", "batch", "result"];
        end

    end

    methods (Static, Access = private)

        function mustBeValidSection(section)

            import openmebius.presentation.status.StatusPresenter

            allowed = ...
                StatusPresenter.allowedSections();

            if ~isscalar(section) || ~ismember(section, allowed)
                error( ...
                    "OpenMebius2:Status:InvalidSection", ...
                    "Section must be one of: model, experiment, batch, result.");
            end

        end

        function mustBeValidStatus(status)

            import openmebius.presentation.status.StatusPresenter

            allowed = ...
                StatusPresenter.allowedStatuses();

            if ~isscalar(status) || ~ismember(status, allowed)
                error( ...
                    "OpenMebius2:Status:InvalidStatus", ...
                    "Status must be one of: init, running, finished, error.");
            end

        end

        function idx = sectionIndex(section)

            import openmebius.presentation.status.StatusPresenter

            sections = ...
                StatusPresenter.allowedSections();

            idx = find(sections == section, 1);

            if isempty(idx)
                error( ...
                    "OpenMebius2:Status:InvalidSection", ...
                    "Unknown status section.");
            end

        end

        function [icon, text] = item(section, status)

            import openmebius.presentation.status.StatusPresenter

            icon = ...
                StatusPresenter.icon(status);

            switch section

                case "model"
                    text = ...
                        StatusPresenter.modelText(status);

                case "experiment"
                    text = ...
                        StatusPresenter.experimentText(status);

                case "batch"
                    text = ...
                        StatusPresenter.batchText(status);

                case "result"
                    text = ...
                        StatusPresenter.resultText(status);

                otherwise
                    error( ...
                        "OpenMebius2:Status:InvalidSection", ...
                        "Unknown status section.");
            end

        end

        function icon = icon(status)

            switch status

                case "init"
                    icon = "ℹ️";

                case "running"
                    icon = "⏳";

                case "finished"
                    icon = "✅";

                case "error"
                    icon = "❌";

                otherwise
                    error( ...
                        "OpenMebius2:Status:InvalidStatus", ...
                        "Unknown status.");
            end

        end

        function text = modelText(status)

            switch status

                case "init"
                    text = "Model not loaded";

                case "running"
                    text = "Loading model...";

                case "finished"
                    text = "Model loaded successfully";

                case "error"
                    text = "Error loading model";
            end

        end

        function text = experimentText(status)

            switch status

                case "init"
                    text = "Experiment data not loaded";

                case "running"
                    text = "Loading experiment data...";

                case "finished"
                    text = "Experiment data loaded successfully";

                case "error"
                    text = "Error loading experiment data";
            end

        end

        function text = batchText(status)

            switch status

                case "init"
                    text = "Batch not started";

                case "running"
                    text = "Running batch...";

                case "finished"
                    text = "Batch run completed successfully";

                case "error"
                    text = "Error in batch run";
            end

        end

        function text = resultText(status)

            switch status

                case "init"
                    text = "Result not loaded";

                case "running"
                    text = "Loading result...";

                case "finished"
                    text = "Result loaded successfully";

                case "error"
                    text = "Error loading result";
            end

        end

    end

end
