classdef EffluxPenalty
    % EFFLUXPENALTY
    % Evaluates the weighted residual of measured free effluxes.

    properties (SetAccess = private)
        Profile (1, 1) openmebius.mfa.EffluxPerturbationProfile
    end

    properties (Dependent, SetAccess = private)
        ReactionIndices (:, 1) double
        ExperimentalValues (:, 1) double
        StandardDeviations (:, 1) double
    end

    methods

        function obj = EffluxPenalty(options)

            arguments
                options.Profile (1, 1) ...
                    openmebius.mfa.EffluxPerturbationProfile = ...
                    openmebius.mfa.EffluxPerturbationProfile()
                options.ReactionIndices (:, 1) double = zeros(0, 1)
                options.ExperimentalValues (:, 1) double = zeros(0, 1)
                options.StandardDeviations (:, 1) double = zeros(0, 1)
            end

            hasLegacyData = ...
                ~isempty(options.ReactionIndices) || ...
                ~isempty(options.ExperimentalValues) || ...
                ~isempty(options.StandardDeviations);

            if hasLegacyData && options.Profile.MeasurementCount > 0
                error( ...
                    "OpenMebius2:EffluxPenalty:ConflictingProfileInput", ...
                    "Specify either an efflux perturbation profile or " + ...
                "legacy efflux vectors, not both.");
            end

            if hasLegacyData

                try
                    obj.Profile = ...
                        openmebius.mfa.EffluxPerturbationProfile( ...
                        ReactionIndices = options.ReactionIndices, ...
                        ExperimentalValues = ...
                        options.ExperimentalValues, ...
                        StandardDeviations = ...
                        options.StandardDeviations);
                catch ME
                    openmebius.mfa.EffluxPenalty ...
                        .rethrowLegacyValidationError(ME);
                end

            else
                obj.Profile = options.Profile;
            end

        end % constructor

        function value = get.ReactionIndices(obj)

            value = obj.Profile.ReactionIndices;

        end

        function value = get.ExperimentalValues(obj)

            value = obj.Profile.ExperimentalValues;

        end

        function value = get.StandardDeviations(obj)

            value = obj.Profile.StandardDeviations;

        end

        function rss = evaluate(obj, flux)

            arguments
                obj (1, 1) openmebius.mfa.EffluxPenalty
                flux (:, :) double
            end

            fluxCount = size(flux, 2);

            if isempty(obj.ReactionIndices)
                rss = zeros(1, fluxCount);
                return;
            end

            if max(obj.ReactionIndices) > size(flux, 1)
                error( ...
                    "OpenMebius2:EffluxPenalty:FluxDimensionMismatch", ...
                "Efflux reaction indices exceed the flux vector length.");
            end

            simulatedValues = flux(obj.ReactionIndices, :);
            normalizedResiduals = ...
                (simulatedValues - obj.ExperimentalValues) ./ ...
                obj.StandardDeviations;
            rss = sum(normalizedResiduals .^ 2, 1);

        end % evaluate

    end % methods

    methods (Static, Access = private)

        function rethrowLegacyValidationError(exception)

            profilePrefix = ...
                "OpenMebius2:EffluxPerturbationProfile:";
            identifier = string(exception.identifier);

            if startsWith(identifier, profilePrefix)
                suffix = extractAfter(identifier, profilePrefix);
                error( ...
                    "OpenMebius2:EffluxPenalty:" + suffix, ...
                    "%s", exception.message);
            end

            rethrow(exception);

        end

    end % methods (Static, Access = private)

end % classdef
