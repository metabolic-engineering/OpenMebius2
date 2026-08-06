classdef EffluxPerturbationSettings
    % EFFLUXPERTURBATIONSETTINGS
    % Typed efflux perturbation settings before model alignment.

    properties (SetAccess = private)
        Enabled (1, 1) logical
        Substrates (:, 1) string
        FreeSelection (:, 1) logical
        StandardDeviations (:, 1) double
        GrowthRateFree (1, 1) logical
        GrowthRateStandardDeviation (1, 1) double
    end

    methods

        function obj = EffluxPerturbationSettings(options)

            arguments
                options.Enabled (1, 1) logical = false
                options.Substrates (:, 1) string = strings(0, 1)
                options.FreeSelection (:, 1) logical = false(0, 1)
                options.StandardDeviations (:, 1) double = zeros(0, 1)
                options.GrowthRateFree (1, 1) logical = false
                options.GrowthRateStandardDeviation (1, 1) double = NaN
            end

            obj.Enabled = options.Enabled;
            obj.Substrates = options.Substrates;
            obj.FreeSelection = options.FreeSelection;
            obj.StandardDeviations = options.StandardDeviations;
            obj.GrowthRateFree = options.GrowthRateFree;
            obj.GrowthRateStandardDeviation = ...
                options.GrowthRateStandardDeviation;

        end

    end

end
