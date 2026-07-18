classdef RunConfigPresenter < handle
    % RUNCONFIGPRESENTER Builds RunConfig values and control state.

    methods

        function viewModel = presentConfig(~, config)

            viewModel = openmebius.presentation.batch ...
                .RunConfigMapper.toViewModel(config);

        end % presentConfig

        function viewModel = presentDefaults(obj)

            config = openmebius.domain.batch.BatchConfig.defaultConfig();
            viewModel = obj.presentConfig(config);

        end % presentDefaults

        function config = applyViewModel(~, viewModel, currentConfig)

            config = openmebius.presentation.batch.RunConfigMapper ...
                .fromViewModel(viewModel, currentConfig);

        end % applyViewModel

        function state = presentControlState(~, viewModel)

            arguments
                ~
                viewModel (1, 1) openmebius.presentation.batch ...
                    .RunConfigViewModel
            end

            isMonteCarlo = false;
            isGrid = false;

            if viewModel.CalculateCI
                switch lower(viewModel.CIAlgorithm)
                    case "monte carlo"
                        isMonteCarlo = true;
                    case "grid search"
                        isGrid = true;
                    otherwise
                        error( ...
                            "OpenMebius2:RunConfigPresenter:" + ...
                            "UnsupportedCIAlgorithm", ...
                            "Unsupported CI algorithm: %s.", ...
                            viewModel.CIAlgorithm);
                end
            end

            state = openmebius.presentation.batch ...
                .RunConfigControlState( ...
                    CIAlgorithmEnabled = viewModel.CalculateCI, ...
                    MonteCarloEnabled = isMonteCarlo, ...
                    GridEnabled = isGrid, ...
                    GridPointsEnabled = isGrid && ...
                        viewModel.GridAutomaticInterval, ...
                    GridDeltaEnabled = isGrid && ...
                        ~viewModel.GridAutomaticInterval, ...
                    EffluxEnabled = viewModel.PerturbateEfflux, ...
                    SuggestionEnabled = viewModel.SuggestNextFlux, ...
                    INSTMFATablesEnabled = viewModel.IsINSTMFA);

        end % presentControlState

    end % methods

end % classdef
