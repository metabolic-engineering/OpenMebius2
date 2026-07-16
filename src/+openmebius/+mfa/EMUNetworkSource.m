classdef EMUNetworkSource
    % EMUNETWORKSOURCE Immutable model tables required for EMU enumeration.

    properties (SetAccess = private)
        MSReactions table
        MSTransitions table
        Reactions table
        Transitions table
        Metabolites table
    end

    methods

        function obj = EMUNetworkSource(options)

            arguments
                options.MSReactions table
                options.MSTransitions table
                options.Reactions table
                options.Transitions table
                options.Metabolites table
            end

            obj.MSReactions = options.MSReactions;
            obj.MSTransitions = options.MSTransitions;
            obj.Reactions = options.Reactions;
            obj.Transitions = options.Transitions;
            obj.Metabolites = options.Metabolites;

        end % constructor

    end % methods

end % classdef
