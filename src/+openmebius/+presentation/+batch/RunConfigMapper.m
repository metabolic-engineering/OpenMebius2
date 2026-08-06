classdef RunConfigMapper
    % RUNCONFIGMAPPER
    % Converts between RunConfig UI labels and BatchConfig values.

    methods (Static)

        function viewModel = toViewModel(config)

            config = openmebius.domain.batch.BatchConfig.normalize(config);
            viewModel = openmebius.presentation.batch.RunConfigViewModel();
            viewModel.Iteration = double(config.iteration);
            viewModel.Algorithm = openmebius.presentation.batch ...
                .RunConfigMapper.algorithmToView(config.algorithm);
            viewModel.LargeScale = logical(config.largeScale);
            viewModel.FluxLowerBound = double(config.fluxLB);
            viewModel.FluxUpperBound = double(config.fluxUB);
            viewModel.FminconMaxFunctionEvaluations = ...
                double(config.fmincon.maxFunctionEvaluations);
            viewModel.FminconMaxIterations = ...
                double(config.fmincon.maxIterations);
            viewModel.FminconFunctionTolerance = ...
                double(config.fmincon.functionTolerance);
            viewModel.FminconStepTolerance = ...
                double(config.fmincon.stepTolerance);
            viewModel.FminconOptimalityTolerance = ...
                double(config.fmincon.optimalityTolerance);
            viewModel.FminconConstraintTolerance = ...
                double(config.fmincon.constraintTolerance);
            viewModel.FminconFiniteDifferenceType = ...
                openmebius.presentation.batch.RunConfigMapper ...
                .finiteDifferenceTypeToView( ...
                config.fmincon.finiteDifferenceType);
            viewModel.FminconFiniteDifferenceStepSize = ...
                double(config.fmincon.finiteDifferenceStepSize);
            viewModel.SearchOptimalFiniteDifferenceStepSize = ...
                logical(config.fmincon ...
                .finiteDifferenceStepSizeSearch.enabled);
            viewModel.FreeEffluxSeedSigmaMultiplier = ...
                double(config.initialFlux ...
                .freeEffluxSeedSigmaMultiplier);
            viewModel.SuggestNextFlux = logical(config.suggestNextFlux);
            viewModel.PerturbateEfflux = ...
                logical(config.perturbateEfflux);
            viewModel.CalculateCI = logical(config.isCalcCI);
            viewModel.CIAlgorithm = openmebius.presentation.batch ...
                .RunConfigMapper.ciAlgorithmToView( ...
                config.CIConf.algorithm);
            viewModel.DeleteResultFile = logical(config.deleteResultFile);

            monteCarlo = config.CIConf.MC;
            viewModel.MCIterations = double(monteCarlo.iteration);
            viewModel.MCFixMID = logical(monteCarlo.fixMID);
            viewModel.MCMIDStandardDeviation = double(monteCarlo.MIDSD);
            viewModel.MCOptimizationProcedure = ...
                openmebius.presentation.batch.RunConfigMapper ...
                .mcOptimizationProcedureToView( ...
                monteCarlo.optimizationProcedure);
            viewModel.MCTerminationTolerance = ...
                double(monteCarlo.terminationTolerance);
            viewModel.MCProximityThreshold = ...
                double(monteCarlo.proximityThreshold);
            viewModel.MCCertainThreshold = ...
                double(monteCarlo.certainThreshold);
            viewModel.MCNumberOfRuns = ...
                double(monteCarlo.theNumberOfRuns);
            viewModel.MCCalculationMethod = ...
                openmebius.presentation.batch.RunConfigMapper ...
                .mcCalculationMethodToView( ...
                monteCarlo.calculationMethod);

            grid = config.CIConf.grid;
            viewModel.GridAutomaticInterval = ...
                strcmpi(string(grid.intervalMode), "automatic");
            viewModel.GridParallelExecution = ...
                strcmpi(string(grid.executionMode), "parallel");
            viewModel.GridPoints = double(grid.points);
            viewModel.GridDelta = double(grid.delta);
            viewModel.GridIterations = double(grid.iteration);
            viewModel.GridThreshold = openmebius.presentation.batch ...
                .RunConfigMapper.gridThresholdToView(grid.threshold);
            viewModel.GridReactionTable = openmebius.presentation.batch ...
                .RunConfigMapper.gridReactionsToTable(grid.reactions);
            viewModel.IsINSTMFA = logical(config.isINSTMFA);
            viewModel.EffluxTable = openmebius.presentation.batch ...
                .RunConfigMapper.effluxToTable(config.efflux);
            [viewModel.INSTMFAPoolTable, ...
                 viewModel.INSTMFATimePointTable] = ...
                openmebius.presentation.batch.RunConfigMapper ...
                .instMFATables(config.INSTMFA);

        end % toViewModel

        function config = fromViewModel(viewModel, currentConfig)

            arguments
                viewModel (1, 1) openmebius.presentation.batch ...
                    .RunConfigViewModel
                currentConfig (1, 1) struct
            end

            config = openmebius.domain.batch.BatchConfig.normalize( ...
                currentConfig);
            config.iteration = viewModel.Iteration;
            config.algorithm = openmebius.presentation.batch ...
                .RunConfigMapper.algorithmToConfig(viewModel.Algorithm);
            config.largeScale = viewModel.LargeScale;
            config.fluxLB = viewModel.FluxLowerBound;
            config.fluxUB = viewModel.FluxUpperBound;
            config.fmincon.maxFunctionEvaluations = ...
                viewModel.FminconMaxFunctionEvaluations;
            config.fmincon.maxIterations = ...
                viewModel.FminconMaxIterations;
            config.fmincon.functionTolerance = ...
                viewModel.FminconFunctionTolerance;
            config.fmincon.stepTolerance = ...
                viewModel.FminconStepTolerance;
            config.fmincon.optimalityTolerance = ...
                viewModel.FminconOptimalityTolerance;
            config.fmincon.constraintTolerance = ...
                viewModel.FminconConstraintTolerance;
            config.fmincon.finiteDifferenceType = ...
                openmebius.presentation.batch.RunConfigMapper ...
                .finiteDifferenceTypeToConfig( ...
                viewModel.FminconFiniteDifferenceType);
            config.fmincon.finiteDifferenceStepSize = ...
                viewModel.FminconFiniteDifferenceStepSize;
            config.fmincon.finiteDifferenceStepSizeSearch.enabled = ...
                viewModel.SearchOptimalFiniteDifferenceStepSize;
            config.initialFlux.freeEffluxSeedSigmaMultiplier = ...
                viewModel.FreeEffluxSeedSigmaMultiplier;
            config.suggestNextFlux = viewModel.SuggestNextFlux;
            config.perturbateEfflux = viewModel.PerturbateEfflux;
            config.isCalcCI = viewModel.CalculateCI;
            config.CIConf.algorithm = openmebius.presentation.batch ...
                .RunConfigMapper.ciAlgorithmToConfig( ...
                viewModel.CIAlgorithm);
            config.deleteResultFile = viewModel.DeleteResultFile;

            config.CIConf.MC.iteration = viewModel.MCIterations;
            config.CIConf.MC.fixMID = viewModel.MCFixMID;
            config.CIConf.MC.MIDSD = ...
                viewModel.MCMIDStandardDeviation;
            config.CIConf.MC.optimizationProcedure = ...
                openmebius.presentation.batch.RunConfigMapper ...
                .mcOptimizationProcedureToConfig( ...
                viewModel.MCOptimizationProcedure);
            config.CIConf.MC.terminationTolerance = ...
                viewModel.MCTerminationTolerance;
            config.CIConf.MC.proximityThreshold = ...
                viewModel.MCProximityThreshold;
            config.CIConf.MC.certainThreshold = ...
                viewModel.MCCertainThreshold;
            config.CIConf.MC.theNumberOfRuns = ...
                viewModel.MCNumberOfRuns;
            config.CIConf.MC.calculationMethod = ...
                openmebius.presentation.batch.RunConfigMapper ...
                .mcCalculationMethodToConfig( ...
                viewModel.MCCalculationMethod);

            if viewModel.GridAutomaticInterval
                config.CIConf.grid.intervalMode = 'automatic';
            else
                config.CIConf.grid.intervalMode = 'fixed-delta';
            end

            if viewModel.GridParallelExecution
                config.CIConf.grid.executionMode = 'parallel';
            else
                config.CIConf.grid.executionMode = 'serial';
            end

            config.CIConf.grid.points = viewModel.GridPoints;
            config.CIConf.grid.delta = viewModel.GridDelta;
            config.CIConf.grid.iteration = viewModel.GridIterations;
            config.CIConf.grid.threshold = ...
                openmebius.presentation.batch.RunConfigMapper ...
                .gridThresholdToConfig(viewModel.GridThreshold);
            config.CIConf.grid.reactions = openmebius.presentation.batch ...
                .RunConfigMapper.gridReactionsFromTable( ...
                viewModel.GridReactionTable);

            if config.perturbateEfflux && ~isempty(viewModel.EffluxTable)
                config.efflux = openmebius.presentation.batch ...
                    .RunConfigMapper.effluxFromTable( ...
                    viewModel.EffluxTable);
            end

            config.isINSTMFA = viewModel.IsINSTMFA;

            if config.isINSTMFA
                config.INSTMFA = openmebius.presentation.batch ...
                    .RunConfigMapper.instMFAFromTables( ...
                    viewModel.INSTMFAPoolTable, ...
                    viewModel.INSTMFATimePointTable);
            end

            openmebius.domain.batch.BatchConfig.validate(config);

        end % fromViewModel

        function viewValue = algorithmToView(configValue)

            value = openmebius.presentation.batch.RunConfigMapper.normalizeValue(configValue, 'algorithm');

            switch value

                case {"interior-point", "interior point", "ipms"}
                    viewValue = 'IPMs';

                case {"sqp", "sqp-legacy"}
                    viewValue = 'SQP';

                otherwise
                    openmebius.presentation.batch.RunConfigMapper.unsupportedValue('algorithm', configValue);
            end

        end % algorithmToView

        function configValue = algorithmToConfig(viewValue)

            value = openmebius.presentation.batch.RunConfigMapper.normalizeValue(viewValue, 'algorithm');

            switch value

                case "ipms"
                    configValue = 'interior-point';

                case "sqp"
                    configValue = 'sqp';

                otherwise
                    openmebius.presentation.batch.RunConfigMapper.unsupportedValue('algorithm', viewValue);
            end

        end % algorithmToConfig

        function viewValue = finiteDifferenceTypeToView(configValue)

            value = openmebius.presentation.batch.RunConfigMapper ...
                .normalizeValue(configValue, 'finite difference type');

            switch value
                case "forward"
                    viewValue = 'Forward';
                case "central"
                    viewValue = 'Central';
                otherwise
                    openmebius.presentation.batch.RunConfigMapper ...
                        .unsupportedValue( ...
                        'finite difference type', configValue);
            end

        end % finiteDifferenceTypeToView

        function configValue = finiteDifferenceTypeToConfig(viewValue)

            configValue = lower(openmebius.presentation.batch ...
                .RunConfigMapper.finiteDifferenceTypeToView(viewValue));

        end % finiteDifferenceTypeToConfig

        function viewValue = ciAlgorithmToView(configValue)

            value = openmebius.presentation.batch.RunConfigMapper.normalizeValue(configValue, 'CI algorithm');

            switch value

                case "monte carlo"
                    viewValue = 'Monte Carlo';

                case "grid search"
                    viewValue = 'Grid search';

                otherwise
                    openmebius.presentation.batch.RunConfigMapper.unsupportedValue('CI algorithm', configValue);
            end

        end % ciAlgorithmToView

        function configValue = ciAlgorithmToConfig(viewValue)

            configValue = openmebius.presentation.batch.RunConfigMapper.ciAlgorithmToView(viewValue);

        end % ciAlgorithmToConfig

        function viewValue = mcOptimizationProcedureToView(configValue)

            value = openmebius.presentation.batch.RunConfigMapper.normalizeValue(configValue, 'MC optimization procedure');

            switch value

                case {"single", "single run"}
                    viewValue = 'Single run';

                case {"multiple", "multiple run"}
                    viewValue = 'Multiple run';

                otherwise
                    openmebius.presentation.batch.RunConfigMapper.unsupportedValue( ...
                        'MC optimization procedure', ...
                        configValue);
            end

        end % mcOptimizationProcedureToView

        function configValue = mcOptimizationProcedureToConfig(viewValue)

            value = openmebius.presentation.batch.RunConfigMapper.normalizeValue(viewValue, 'MC optimization procedure');

            switch value

                case {"single", "single run"}
                    configValue = 'single';

                case {"multiple", "multiple run"}
                    configValue = 'multiple';

                otherwise
                    openmebius.presentation.batch.RunConfigMapper.unsupportedValue( ...
                        'MC optimization procedure', ...
                        viewValue);
            end

        end % mcOptimizationProcedureToConfig

        function viewValue = mcCalculationMethodToView(configValue)

            value = openmebius.presentation.batch.RunConfigMapper.normalizeValue(configValue, 'MC calculation method');

            switch value

                case "discarding"
                    viewValue = 'Discarding';

                case "mean-varianced"
                    viewValue = 'Mean-varianced';

                otherwise
                    openmebius.presentation.batch.RunConfigMapper.unsupportedValue('MC calculation method', configValue);
            end

        end % mcCalculationMethodToView

        function configValue = mcCalculationMethodToConfig(viewValue)

            value = openmebius.presentation.batch.RunConfigMapper.normalizeValue(viewValue, 'MC calculation method');

            switch value

                case "discarding"
                    configValue = 'discarding';

                case "mean-varianced"
                    configValue = 'mean-varianced';

                otherwise
                    openmebius.presentation.batch.RunConfigMapper.unsupportedValue('MC calculation method', viewValue);
            end

        end % mcCalculationMethodToConfig

        function viewValue = gridThresholdToView(configValue)

            value = openmebius.presentation.batch.RunConfigMapper.normalizeValue(configValue, 'grid threshold');

            switch value

                case {"chi-sq", "chi-squared"}
                    viewValue = 'Chi-squared';

                case {"f-dist", "f-distribution", "f distribution"}
                    viewValue = 'F-distribution';

                otherwise
                    openmebius.presentation.batch.RunConfigMapper.unsupportedValue('grid threshold', configValue);
            end

        end % gridThresholdToView

        function configValue = gridThresholdToConfig(viewValue)

            value = openmebius.presentation.batch.RunConfigMapper.normalizeValue(viewValue, 'grid threshold');

            switch value

                case {"chi-sq", "chi-squared"}
                    configValue = 'chi-sq';

                case {"f-dist", "f-distribution", "f distribution"}
                    configValue = 'f-distribution';

                otherwise
                    openmebius.presentation.batch.RunConfigMapper.unsupportedValue('grid threshold', viewValue);
            end

        end % gridThresholdToConfig

    end % methods

    methods (Static, Access = private)

        function tableData = gridReactionsToTable(config)

            selection = logical(config.select(:));
            reactionIDs = string(config.id(:));
            reactions = string(config.reaction(:));

            if numel(selection) ~= numel(reactionIDs) || ...
                    numel(selection) ~= numel(reactions)
                openmebius.presentation.batch.RunConfigMapper ...
                    .invalidTable( ...
                    "Grid reaction values must have matching " + ...
                "lengths.");
            end

            tableData = table( ...
                selection, reactionIDs, reactions, ...
                'VariableNames', {'Select', 'ID', 'Reaction'});

        end % gridReactionsToTable

        function config = gridReactionsFromTable(tableData)

            if isempty(tableData) && width(tableData) == 0
                config = struct( ...
                    select = logical([]), ...
                    id = string([]), ...
                    reaction = string([]));
                return
            end

            openmebius.presentation.batch.RunConfigMapper ...
                .requireTableVariables( ...
                tableData, ...
                ["Select", "ID", "Reaction"], ...
            "Grid reaction");
            config = struct( ...
                select = logical(tableData.Select(:)), ...
                id = string(tableData.ID(:)), ...
                reaction = string(tableData.Reaction(:)));

        end % gridReactionsFromTable

        function tableData = effluxToTable(config)

            growthRateRow = "mu (growth rate)";
            selection = logical(config.selection(:));
            substrates = string(config.substrate(:));
            standardDeviations = double(config.substrateSD(:));
            muSelection = logical(config.muSelection);
            muSD = double(config.muSD);

            if numel(selection) ~= numel(substrates) || ...
                    numel(standardDeviations) ~= numel(substrates) || ...
                    any(strlength(substrates) == 0) || ...
                    numel(unique(substrates)) ~= numel(substrates)
                openmebius.presentation.batch.RunConfigMapper ...
                    .invalidTable( ...
                    "Efflux values must have matching, unique " + ...
                "substrate rows.");
            end

            tableData = table( ...
                [muSelection; selection], ...
                [muSD; standardDeviations], ...
                'VariableNames', {'Selection', 'SD'}, ...
                'RowNames', cellstr([growthRateRow; substrates]));

        end % effluxToTable

        function config = effluxFromTable(tableData)

            openmebius.presentation.batch.RunConfigMapper ...
                .requireTableVariables( ...
                tableData, ["Selection", "SD"], "Flux perturbation");
            growthRateRow = "mu (growth rate)";
            rowNames = string(tableData.Properties.RowNames(:));

            if numel(rowNames) ~= height(tableData) || ...
                    any(strlength(rowNames) == 0) || ...
                    sum(rowNames == growthRateRow) > 1
                openmebius.presentation.batch.RunConfigMapper ...
                    .invalidTable( ...
                    "Flux perturbation table requires one row name " + ...
                "for each row.");
            end

            muMask = rowNames == growthRateRow;
            muSelection = false;
            muSD = NaN;

            if any(muMask)
                muSelection = logical(tableData.Selection(muMask));
                muSD = double(tableData.SD(muMask));
            end

            substrates = rowNames(~muMask);

            config = struct( ...
                selection = logical(tableData.Selection(~muMask)), ...
                substrate = substrates, ...
                substrateSD = double(tableData.SD(~muMask)), ...
                muSelection = muSelection, ...
                muSD = muSD);

        end % effluxFromTable

        function [poolTable, timePointTable] = instMFATables(config)

            metabolites = string(config.poolMetabolite(:));
            poolSizes = double(config.poolSize(:));
            experimentNames = string(config.timePointsExpName(:));
            timePoints = double(config.timePoints(:));

            if numel(metabolites) ~= numel(poolSizes) || ...
                    numel(experimentNames) ~= numel(timePoints)
                openmebius.presentation.batch.RunConfigMapper ...
                    .invalidTable( ...
                    "INST-MFA names and values must have matching " + ...
                "lengths.");
            end

            poolTable = table( ...
                metabolites, poolSizes, ...
                'VariableNames', {'Metabolite', 'PoolSize'});
            timePointTable = table( ...
                experimentNames, timePoints, ...
                'VariableNames', {'TimePointExpName', 'TimePoint'});

        end % instMFATables

        function config = instMFAFromTables(poolTable, timePointTable)

            if isempty(poolTable) && width(poolTable) == 0
                metabolites = strings(0, 1);
                poolSizes = zeros(0, 1);
            else
                openmebius.presentation.batch.RunConfigMapper ...
                    .requireTableVariables( ...
                    poolTable, ...
                    ["Metabolite", "PoolSize"], ...
                "INST-MFA pool");
                metabolites = string(poolTable.Metabolite(:));
                poolSizes = double(poolTable.PoolSize(:));
            end

            if isempty(timePointTable) && width(timePointTable) == 0
                experimentNames = strings(0, 1);
                timePoints = zeros(0, 1);
            else
                openmebius.presentation.batch.RunConfigMapper ...
                    .requireTableVariables( ...
                    timePointTable, ...
                    ["TimePointExpName", "TimePoint"], ...
                "INST-MFA time-point");
                experimentNames = ...
                    string(timePointTable.TimePointExpName(:));
                timePoints = double(timePointTable.TimePoint(:));
            end

            config = struct( ...
                poolMetabolite = metabolites, ...
                poolSize = poolSizes, ...
                timePointsExpName = experimentNames, ...
                timePoints = timePoints);

        end % instMFAFromTables

        function requireTableVariables(tableData, required, label)

            actual = string(tableData.Properties.VariableNames);

            if ~all(ismember(required, actual))
                openmebius.presentation.batch.RunConfigMapper ...
                    .invalidTable( ...
                    label + " table must contain " + ...
                    strjoin(required, ", ") + ".");
            end

        end % requireTableVariables

        function invalidTable(message)

            error( ...
                "OpenMebius2:RunConfigMapper:InvalidTable", ...
                "%s", ...
                message);

        end % invalidTable

        function value = normalizeValue(value, fieldName)

            if ~(ischar(value) || isstring(value)) || isempty(value)
                error( ...
                    "OpenMebius2:RunConfigMapper:InvalidString", ...
                    "RunConfig %s value must be a string.", ...
                    fieldName);
            end

            value = lower(strtrim(string(value)));

            if ~isscalar(value)
                error( ...
                    "OpenMebius2:RunConfigMapper:InvalidString", ...
                    "RunConfig %s value must be a scalar string.", ...
                    fieldName);
            end

        end % normalizeValue

        function unsupportedValue(fieldName, value)

            error( ...
                "OpenMebius2:RunConfigMapper:UnsupportedValue", ...
                "Unsupported RunConfig %s value: %s.", ...
                fieldName, ...
                string(value));

        end % unsupportedValue

    end % methods

end % classdef
