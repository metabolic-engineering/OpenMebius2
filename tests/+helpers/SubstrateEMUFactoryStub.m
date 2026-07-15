classdef SubstrateEMUFactoryStub

    methods

        function emu = fromExperiment(~, ~, ~, experiment)

            emu = double(experiment);

        end

        function emu = fromPattern(~, ~, ~, pattern)

            emu = 10 + numel(pattern);

        end

    end

end
