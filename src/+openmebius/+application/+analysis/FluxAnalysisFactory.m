classdef FluxAnalysisFactory
    % FLUXANALYSISFACTORY Creates the legacy FluxAnalysis facade.

    methods

        function analysis = create( ...
                ~, model, experiments, experimentNames, config, ...
                resultInput, batchId, controller, options)

            arguments
                ~
                model
                experiments
                experimentNames
                config (1, 1) struct
                resultInput
                batchId
                controller = []
                options.Provenance (1, 1) struct = struct
            end

            analysis = FluxAnalysis( ...
                model, ...
                experiments, ...
                experimentNames, ...
                config, ...
                resultInput, ...
                batchId, ...
                controller, ...
                Provenance = options.Provenance);

        end % create

    end % methods

end % classdef
