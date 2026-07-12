classdef RunConfigMapper
    % RUNCONFIGMAPPER
    % Converts between RunConfig UI labels and BatchConfig values.

    methods (Static)

        function viewModel = toViewModel(config)

            viewModel = struct;
            viewModel.Algorithm = openmebius.presentation.batch.RunConfigMapper.algorithmToView(config.algorithm);
            viewModel.CIAlgorithm = openmebius.presentation.batch.RunConfigMapper.ciAlgorithmToView(config.CIConf.algorithm);
            viewModel.MCOptimizationProcedure = openmebius.presentation.batch.RunConfigMapper.mcOptimizationProcedureToView( ...
                config.CIConf.MC.optimizationProcedure);
            viewModel.MCCalculationMethod = openmebius.presentation.batch.RunConfigMapper.mcCalculationMethodToView( ...
                config.CIConf.MC.calculationMethod);
            viewModel.GridThreshold = openmebius.presentation.batch.RunConfigMapper.gridThresholdToView( ...
                config.CIConf.grid.threshold);

        end % toViewModel

        function config = fromViewModel(viewModel, currentConfig)

            config = currentConfig;

            if isfield(viewModel, 'Algorithm')
                config.algorithm = openmebius.presentation.batch.RunConfigMapper.algorithmToConfig(viewModel.Algorithm);
            end

            if isfield(viewModel, 'CIAlgorithm')
                config.CIConf.algorithm = openmebius.presentation.batch.RunConfigMapper.ciAlgorithmToConfig( ...
                    viewModel.CIAlgorithm);
            end

            if isfield(viewModel, 'MCOptimizationProcedure')
                config.CIConf.MC.optimizationProcedure = ...
                    openmebius.presentation.batch.RunConfigMapper.mcOptimizationProcedureToConfig( ...
                    viewModel.MCOptimizationProcedure);
            end

            if isfield(viewModel, 'MCCalculationMethod')
                config.CIConf.MC.calculationMethod = ...
                    openmebius.presentation.batch.RunConfigMapper.mcCalculationMethodToConfig( ...
                    viewModel.MCCalculationMethod);
            end

            if isfield(viewModel, 'GridThreshold')
                config.CIConf.grid.threshold = ...
                    openmebius.presentation.batch.RunConfigMapper.gridThresholdToConfig(viewModel.GridThreshold);
            end

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
