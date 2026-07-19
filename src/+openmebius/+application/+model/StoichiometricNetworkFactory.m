classdef StoichiometricNetworkFactory
    % STOICHIOMETRICNETWORKFACTORY Builds a network from a loaded workspace.

    properties (Access = private)
        MatrixBuilder
    end

    methods
        function obj = StoichiometricNetworkFactory(options)
            arguments
                options.MatrixBuilder = ...
                    openmebius.mfa.StoichiometricMatrixBuilder()
            end
            obj.MatrixBuilder = options.MatrixBuilder;
        end

        function network = create(obj, workspace)
            reactionIndex = ...
                openmebius.domain.model.StoichiometricReactionIndex( ...
                    workspace.getModelTable(), ...
                    workspace.getParsedReactionTable(), ...
                    workspace.getParsedTransitionTable());
            constraints = obj.MatrixBuilder.build( ...
                reactionIndex, workspace.getMetaboliteTable(), ...
                workspace.getBiomassTable());
            network = openmebius.domain.model.StoichiometricNetwork( ...
                reactionIndex, constraints, workspace.getMetaboliteTable());
        end
    end
end
