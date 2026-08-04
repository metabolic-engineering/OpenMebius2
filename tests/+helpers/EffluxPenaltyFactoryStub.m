classdef EffluxPenaltyFactoryStub

    methods

        function [penalty, profile] = create(~, varargin)

            profile = openmebius.mfa.EffluxPerturbationProfile();
            penalty = openmebius.mfa.EffluxPenalty( ...
                Profile = profile);

        end

    end

end
