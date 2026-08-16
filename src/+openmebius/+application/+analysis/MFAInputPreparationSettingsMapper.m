classdef MFAInputPreparationSettingsMapper
    % MFAINPUTPREPARATIONSETTINGSMAPPER
    % Maps persisted Batch input settings to typed preparation settings.

    methods (Static)

        function settings = fromBatchConfig(config)

            arguments
                config (1, 1) struct
            end

            settings = openmebius.application.analysis ...
                .MFAInputPreparationSettings( ...
                EffluxPerturbation = ...
                openmebius.application.analysis ...
                .MFAInputPreparationSettingsMapper ...
                .mapEffluxPerturbation(config), ...
                FragmentSelection = ...
                openmebius.application.analysis ...
                .MFAInputPreparationSettingsMapper ...
                .mapFragmentSelection(config));

        end % fromBatchConfig

    end % methods (Static)

    methods (Static, Access = private)

        function settings = mapEffluxPerturbation(config)

            enabled = false;

            if isfield(config, 'perturbateEfflux') && ...
                    ~isempty(config.perturbateEfflux)
                candidate = config.perturbateEfflux;

                if ~(islogical(candidate) || isnumeric(candidate)) || ...
                        ~isscalar(candidate)
                    error( ...
                        "OpenMebius2:MFAInputPreparationSettingsMapper:" + ...
                        "InvalidEffluxPerturbationFlag", ...
                        "Efflux perturbation flag must be a logical " + ...
                        "scalar.");
                end

                enabled = logical(candidate);
            end

            substrates = strings(0, 1);
            freeSelection = false(0, 1);
            standardDeviations = zeros(0, 1);
            growthRateFree = false;
            growthRateStandardDeviation = NaN;

            if isfield(config, 'efflux') && ...
                    isstruct(config.efflux) && isscalar(config.efflux)
                efflux = config.efflux;

                if isfield(efflux, 'substrate')
                    substrates = string(efflux.substrate(:));
                end

                if isfield(efflux, 'selection')
                    freeSelection = logical(efflux.selection(:));
                end

                if isfield(efflux, 'substrateSD')
                    standardDeviations = double(efflux.substrateSD(:));
                end

                if isfield(efflux, 'muSelection')
                    growthRateFree = logical(efflux.muSelection);
                end

                if isfield(efflux, 'muSD')
                    growthRateStandardDeviation = double(efflux.muSD);
                end

            end

            settings = openmebius.mfa.EffluxPerturbationSettings( ...
                Enabled = enabled, ...
                Substrates = substrates, ...
                FreeSelection = freeSelection, ...
                StandardDeviations = standardDeviations, ...
                GrowthRateFree = growthRateFree, ...
                GrowthRateStandardDeviation = ...
                growthRateStandardDeviation);

        end % mapEffluxPerturbation

        function selection = mapFragmentSelection(config)

            if ~isfield(config, 'MS') || ~isstruct(config.MS) || ...
                    ~isscalar(config.MS) || ...
                    ~isfield(config.MS, 'fragment') || ...
                    isempty(config.MS.fragment)
                selection = openmebius.mfa.MSFragmentSelection();
                return
            end

            candidate = lower(string(config.MS.fragment));

            if ~isscalar(candidate)
                error( ...
                    "OpenMebius2:MFAInputPreparationSettingsMapper:" + ...
                    "InvalidFragmentSelectionMode", ...
                    "MS fragment selection mode must be scalar.");
            end

            switch candidate
                case "all"
                    selection = openmebius.mfa.MSFragmentSelection();
                case "custom"
                    fragments = strings(0, 1);
                    selectedMask = false(0, 1);

                    if isfield(config.MS, 'fragmentList')
                        fragments = string(config.MS.fragmentList(:));
                    end

                    if isfield(config.MS, 'customFragment')
                        selectedMask = ...
                            logical(config.MS.customFragment(:));
                    end

                    selection = openmebius.mfa.MSFragmentSelection( ...
                        Mode = openmebius.mfa ...
                        .MSFragmentSelectionMode.CustomSelection, ...
                        Fragments = fragments, ...
                        SelectedMask = selectedMask);
                otherwise
                    error( ...
                        "OpenMebius2:" + ...
                        "MFAInputPreparationSettingsMapper:" + ...
                        "InvalidFragmentSelectionMode", ...
                        "Unknown MS fragment selection mode '%s'.", ...
                        candidate);
            end

        end % mapFragmentSelection

    end % methods (Static, Access = private)

end
