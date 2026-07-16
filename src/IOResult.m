classdef IOResult < openmebius.application.result.ResultWorkspace
    % IORESULT Compatibility adapter for the legacy result API.

    methods

        function obj = IOResult(resultInput, options)

            arguments
                resultInput
                options.ResultRepository = ...
                    openmebius.infrastructure.result.ResultRepository()
                options.Hdf5ResultRepository = ...
                    openmebius.infrastructure.result ...
                    .Hdf5ResultRepository()
            end

            obj@openmebius.application.result.ResultWorkspace( ...
                resultInput, ...
                ResultRepository = options.ResultRepository, ...
                Hdf5ResultRepository = options.Hdf5ResultRepository);

        end

    end

end
