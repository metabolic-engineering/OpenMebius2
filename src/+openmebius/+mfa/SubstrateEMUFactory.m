classdef SubstrateEMUFactory
    % SUBSTRATEEMUFACTORY
    % Resolves substrate EMUs from experiment or custom tracer patterns.

    methods

        function emu = fromExperiment( ...
                ~, model, experiments, experiment)

            model.substrateEMUsAll();
            tracerTable = experiments.getTracerTable();
            openmebius.mfa.SubstrateEMUFactory ...
                .validateTracerTable(tracerTable);

            try
                tracerPattern = tracerTable{experiment, :};
            catch
                error( ...
                    "OpenMebius2:SubstrateEMUFactory:" + ...
                    "ExperimentNotFound", ...
                    "Tracer data was not found for the requested " + ...
                "experiment.");
            end

            emu = openmebius.mfa.SubstrateEMUFactory.assemble( ...
                model, tracerTable, tracerPattern);

        end % fromExperiment

        function emu = fromPattern( ...
                ~, model, experiments, tracerPattern)

            model.substrateEMUsAll();
            tracerTable = experiments.getTracerTable();
            openmebius.mfa.SubstrateEMUFactory ...
                .validateTracerTable(tracerTable);
            emu = openmebius.mfa.SubstrateEMUFactory.assemble( ...
                model, tracerTable, tracerPattern);

        end % fromPattern

    end % methods

    methods (Static, Access = private)

        function emu = assemble(model, tracerTable, tracerPattern)

            tracerPattern = string(tracerPattern);
            tracerPattern = tracerPattern(:).';
            substrateNames = string( ...
                tracerTable.Properties.VariableNames);

            if numel(tracerPattern) ~= numel(substrateNames)
                error( ...
                    "OpenMebius2:SubstrateEMUFactory:" + ...
                    "TracerDimensionMismatch", ...
                "Each substrate must have one tracer pattern.");
            end

            [~, substrateOrder] = sort(substrateNames);
            tracerPattern = tracerPattern(substrateOrder);
            tracerPattern = regexprep(tracerPattern, "~.*", "");
            tracerDefinitions = model.getTableLabelView();

            if ~ismember( ...
                    'Name', tracerDefinitions.Properties.VariableNames)
                error( ...
                    "OpenMebius2:SubstrateEMUFactory:" + ...
                    "MissingTracerNames", ...
                    "The model tracer definitions must provide a Name " + ...
                "column.");
            end

            template = model.getLabelStructEMU();
            templateFields = fieldnames(template);
            definitionNames = string(tracerDefinitions.Name);
            definitionNames = definitionNames(:);

            if numel(templateFields) ~= numel(definitionNames)
                error( ...
                    "OpenMebius2:SubstrateEMUFactory:" + ...
                    "TemplateDimensionMismatch", ...
                    "Tracer definitions and substrate EMU templates " + ...
                "must have matching dimensions.");
            end

            emuParts = cell(numel(tracerPattern), 1);

            for tracerIndex = 1:numel(tracerPattern)
                definitionIndex = find( ...
                    definitionNames == tracerPattern(tracerIndex));

                if numel(definitionIndex) ~= 1
                    error( ...
                        "OpenMebius2:SubstrateEMUFactory:" + ...
                        "TracerDefinitionMismatch", ...
                        "Tracer pattern '%s' must match exactly one model " + ...
                        "definition.", ...
                        tracerPattern(tracerIndex));
                end

                fieldName = templateFields{definitionIndex};
                emuParts{tracerIndex} = template.(fieldName);
            end

            try
                emu = vertcat(emuParts{:});
            catch
                error( ...
                    "OpenMebius2:SubstrateEMUFactory:" + ...
                    "IncompatibleEMUTemplates", ...
                    "Selected substrate EMU templates cannot be " + ...
                "concatenated.");
            end

        end % assemble

        function validateTracerTable(tracerTable)

            if ~istable(tracerTable) || ...
                    isempty(tracerTable.Properties.VariableNames)
                error( ...
                    "OpenMebius2:SubstrateEMUFactory:" + ...
                    "MissingTracerData", ...
                "Experiment tracer data is not available.");
            end

        end % validateTracerTable

    end % methods (Static, Access = private)

end % classdef
