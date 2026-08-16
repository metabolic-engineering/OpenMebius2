classdef EffluxPenaltyFactory
    % EFFLUXPENALTYFACTORY
    % Creates an immutable penalty from a shared efflux profile.

    properties (SetAccess = private)
        ProfileFactory
    end

    methods

        function obj = EffluxPenaltyFactory(options)

            arguments
                options.ProfileFactory = openmebius.mfa ...
                    .EffluxPerturbationProfileFactory()
            end

            if ~ismethod(options.ProfileFactory, 'create')
                error( ...
                    "OpenMebius2:EffluxPenaltyFactory:" + ...
                    "InvalidProfileFactory", ...
                    "The efflux profile factory must implement " + ...
                    "create().");
            end

            obj.ProfileFactory = options.ProfileFactory;

        end

        function [penalty, profile] = create( ...
                obj, model, substrateList, experimentalValues, ...
                standardDeviations, freeMask, options)

            arguments
                obj (1, 1) openmebius.mfa.EffluxPenaltyFactory
                model
                substrateList
                experimentalValues double
                standardDeviations double
                freeMask
                options.GrowthRate (1, 1) double = NaN
                options.GrowthRateStandardDeviation (1, 1) double = NaN
                options.GrowthRateFree (1, 1) logical = false
            end

            profile = obj.ProfileFactory.create( ...
                model, ...
                substrateList, ...
                experimentalValues, ...
                standardDeviations, ...
                freeMask, ...
                GrowthRate = options.GrowthRate, ...
                GrowthRateStandardDeviation = ...
                options.GrowthRateStandardDeviation, ...
                GrowthRateFree = options.GrowthRateFree);
            penalty = openmebius.mfa.EffluxPenalty( ...
                Profile = profile);

        end % create

    end % methods

end % classdef
