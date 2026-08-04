classdef ExperimentEditValidator
    % EXPERIMENTEDITVALIDATOR Validates editable aggregate experiment tables.

    methods (Static)

        function report = validateTracer( ...
                data, expectedVariables, expectedSamples, availableTracers)

            report = openmebius.domain.experiment ...
                .ExperimentEditValidator.validateShape( ...
                data, expectedVariables, expectedSamples);

            if ~report.IsValid
                return
            end

            availableTracers = strip(string(availableTracers(:)));
            variables = data.Properties.VariableNames;

            for rowIndex = 1:height(data)

                for variableIndex = 1:numel(variables)
                    value = openmebius.domain.experiment ...
                        .ExperimentEditValidator.toStringScalar( ...
                        data{rowIndex, variableIndex});

                    if strlength(strip(value)) == 0
                        continue
                    end

                    definitions = strip(split(value, ";"));
                    definitions = definitions(strlength(definitions) > 0);

                    for definitionIndex = 1:numel(definitions)
                        parts = strip(split( ...
                            definitions(definitionIndex), "~"));

                        if numel(parts) ~= 2
                            report = openmebius.domain.experiment ...
                                .ExperimentValidationReport.failure( ...
                            "Each tracer must use the label~ratio format.");
                            return
                        end

                        ratio = str2double(parts(2));

                        if ~isfinite(ratio) || ratio < 0 || ratio > 1
                            report = openmebius.domain.experiment ...
                                .ExperimentValidationReport.failure( ...
                            "Tracer ratios must be between 0 and 1.");
                            return
                        end

                        if ~ismember(parts(1), availableTracers)
                            report = openmebius.domain.experiment ...
                                .ExperimentValidationReport.failure( ...
                                "The tracer label '" + parts(1) + ...
                            "' is not available in the model.");
                            return
                        end

                    end

                end

            end

            report = openmebius.domain.experiment ...
                .ExperimentValidationReport.success();

        end % validateTracer

        function report = validateUptake( ...
                data, expectedVariables, expectedSamples)

            report = openmebius.domain.experiment ...
                .ExperimentEditValidator.validateShape( ...
                data, expectedVariables, expectedSamples);

            if ~report.IsValid
                return
            end

            variables = data.Properties.VariableNames;

            for variableIndex = 1:numel(variables)
                values = data.(variables{variableIndex});

                if ~isnumeric(values) || ~isreal(values) || ...
                        any(~isfinite(values(~isnan(values))), "all")
                    report = openmebius.domain.experiment ...
                        .ExperimentValidationReport.failure( ...
                    "Uptake values must be real finite numbers or NaN.");
                    return
                end

            end

            report = openmebius.domain.experiment ...
                .ExperimentValidationReport.success();

        end % validateUptake

        function report = validateShape( ...
                data, expectedVariables, expectedSamples)

            if ~istable(data) || isempty(data)
                report = openmebius.domain.experiment ...
                    .ExperimentValidationReport.failure( ...
                "The experiment table is empty or is not a table.");
                return
            end

            actualVariables = string(data.Properties.VariableNames);
            expectedVariables = reshape(string(expectedVariables), 1, []);

            if ~isequal(actualVariables, expectedVariables)
                report = openmebius.domain.experiment ...
                    .ExperimentValidationReport.failure( ...
                "The table does not have the correct variable names.");
                return
            end

            actualSamples = string(data.Properties.RowNames);
            expectedSamples = string(expectedSamples(:));

            if ~isequal(sort(actualSamples(:)), sort(expectedSamples(:)))
                report = openmebius.domain.experiment ...
                    .ExperimentValidationReport.failure( ...
                "The table does not have the correct sample names.");
                return
            end

            report = openmebius.domain.experiment ...
                .ExperimentValidationReport.success();

        end % validateShape

    end % methods (Static)

    methods (Static, Access = private)

        function value = toStringScalar(value)

            if isempty(value)
                value = "";
                return
            end

            if iscell(value)
                value = openmebius.domain.experiment ...
                    .ExperimentEditValidator.toStringScalar(value{1});
                return
            end

            value = string(value);

            if isempty(value) || ismissing(value(1))
                value = "";
                return
            end

            value = value(1);

        end % toStringScalar

    end % methods (Static, Access = private)

end % classdef
