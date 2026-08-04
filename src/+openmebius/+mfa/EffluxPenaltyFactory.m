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

        function penalty = create( ...
                obj, model, substrateList, experimentalValues, ...
                standardDeviations, freeMask)

            arguments
                obj (1, 1) openmebius.mfa.EffluxPenaltyFactory
                model
                substrateList
                experimentalValues double
                standardDeviations double
                freeMask
            end

            profile = obj.ProfileFactory.create( ...
                model, ...
                substrateList, ...
                experimentalValues, ...
                standardDeviations, ...
                freeMask);
            penalty = openmebius.mfa.EffluxPenalty( ...
                Profile = profile);

        end % create

    end % methods

end % classdef
