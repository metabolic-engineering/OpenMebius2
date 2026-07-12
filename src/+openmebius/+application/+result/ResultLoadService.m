classdef ResultLoadService < handle

    properties (Access = private)
        ResultRepository
    end

    methods

        function obj = ResultLoadService(options)

            arguments
                options.ResultRepository = ...
                    openmebius.infrastructure.legacy.LegacyResultRepository()
            end

            obj.ResultRepository = options.ResultRepository;

        end

        function result = load(obj, resultLocation)

            arguments
                obj
                resultLocation openmebius.domain.result.ResultLocation
            end

            openmebius.application.result.ResultLoadService ...
                .validateResultDirectory(resultLocation);

            ioResult = obj.ResultRepository.open(resultLocation);

            result = openmebius.application.result.ResultLoadResult( ...
                Result = ioResult, ...
                ResultLocation = resultLocation, ...
                Messages = "Result object opened successfully.");

        end

    end

    methods (Static, Access = private)

        function validateResultDirectory(resultLocation)

            resultDirectory = resultLocation.Directory;

            if resultDirectory == ""
                error( ...
                    "OpenMebius2:ResultLoad:EmptyDirectory", ...
                    "Result directory is empty.");
            end

            if ~isfolder(resultDirectory)
                error( ...
                    "OpenMebius2:ResultLoad:DirectoryNotFound", ...
                    "Result directory does not exist: %s", ...
                    resultDirectory);
            end

        end

    end

end
