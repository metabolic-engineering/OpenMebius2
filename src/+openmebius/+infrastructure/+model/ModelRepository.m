classdef ModelRepository < handle
    % MODELREPOSITORY
    % Loads model objects and model-owned files.

    properties (Access = private)
        CacheRepository
        NetworkBuilder
        MatrixBuilder
        NetworkEnumerator
        StoichiometricNetworkFactory
    end

    methods

        function obj = ModelRepository(options)

            arguments
                options.CacheRepository = ...
                    openmebius.infrastructure.model ...
                        .EMUNetworkCacheRepository()
                options.NetworkBuilder = openmebius.mfa.EMUNetworkBuilder()
                options.MatrixBuilder = openmebius.mfa.EMUMatrixBuilder()
                options.NetworkEnumerator = ...
                    openmebius.mfa.EMUNetworkEnumerator()
                options.StoichiometricNetworkFactory = ...
                    openmebius.application.model ...
                        .StoichiometricNetworkFactory()
            end

            obj.CacheRepository = options.CacheRepository;
            obj.NetworkBuilder = options.NetworkBuilder;
            obj.MatrixBuilder = options.MatrixBuilder;
            obj.NetworkEnumerator = options.NetworkEnumerator;
            obj.StoichiometricNetworkFactory = ...
                options.StoichiometricNetworkFactory;

        end % constructor

        function model = load(obj, modelLocation)

            arguments
                obj
                modelLocation openmebius.domain.model.ModelLocation
            end

            document = openmebius.application.model.ModelDocument( ...
                modelLocation, ModelRepository = obj);
            stoichiometricNetwork = ...
                obj.StoichiometricNetworkFactory.create(document);
            model = openmebius.application.model.MetabolicModel( ...
                document, ...
                stoichiometricNetwork, ...
                NetworkBuilder = obj.NetworkBuilder, ...
                MatrixBuilder = obj.MatrixBuilder, ...
                NetworkEnumerator = obj.NetworkEnumerator, ...
                StoichiometricNetworkFactory = ...
                    obj.StoichiometricNetworkFactory);

            [fileName, fileType] = document.getModelFileDescriptor();
            isLoaded = false;
            try
                [snapshot, isLoaded] = obj.CacheRepository.load( ...
                    modelLocation, fileName, fileType);
            catch
                snapshot = [];
            end

            if isLoaded
                model.restoreEMUNetwork(snapshot);
            else
                model.constructEMUNetwork();
                try
                    obj.CacheRepository.save( ...
                        modelLocation, fileName, fileType, ...
                        model.getEMUNetworkSnapshot());
                catch
                    % A cache failure must not invalidate the loaded model.
                end
            end

            if isempty(model) || ~isvalid(model)
                error( ...
                    "OpenMebius2:ModelRepository:InvalidModelObject", ...
                    "Failed to create the metabolic model.");
            end

        end % load

        function assertModelDirectory(~, modelLocation)

            arguments
                ~
                modelLocation openmebius.domain.model.ModelLocation
            end

            try
                openmebius.infrastructure.filesystem.DirectoryStore ...
                    .assertDirectoryExists(modelLocation.Directory);
            catch ME
                if string(ME.identifier) ~= ...
                        "OpenMebius2:DirectoryStore:DirectoryNotFound"
                    rethrow(ME);
                end

                error( ...
                    "OpenMebius2:ModelRepository:DirectoryNotFound", ...
                    "Model directory does not exist: %s", ...
                    modelLocation.Directory);
            end

        end % assertModelDirectory

        function data = readModelSheet(~, modelLocation, fileName, fileType, sheetName, options)

            arguments
                ~
                modelLocation openmebius.domain.model.ModelLocation
                fileName (1, 1) string
                fileType (1, 1) string
                sheetName (1, 1) string
                options.ReadRowNames (1, 1) logical = true
                options.ReadVariableNames (1, 1) logical = true
                options.RefTypes (1, :) string = []
                options.RefVariableNames (1, :) string = []
            end

            if fileType ~= "xlsx"
                error( ...
                    "OpenMebius2:ModelRepository:UnsupportedModelFileType", ...
                    "The file type %s is not supported.", ...
                    fileType);
            end

            pathFile = modelLocation.modelFile(fileName, fileType);

            try
                data = openmebius.infrastructure.filesystem.ExcelFileStore ...
                    .readTable( ...
                    pathFile, ...
                    sheetName, ...
                    ReadRowNames = options.ReadRowNames, ...
                    ReadVariableNames = options.ReadVariableNames, ...
                    RefTypes = options.RefTypes, ...
                    RefVariableNames = options.RefVariableNames);
            catch ME
                openmebius.infrastructure.model.ModelRepository ...
                    .throwModelSheetReadError(pathFile, ME);
            end

        end % readModelSheet

        function label = readLabel(~, modelLocation, fileName, fileType)

            arguments
                ~
                modelLocation openmebius.domain.model.ModelLocation
                fileName (1, 1) string
                fileType (1, 1) string
            end

            pathFile = modelLocation.labelFile(fileName, fileType);

            try
                label = openmebius.infrastructure.filesystem.JsonFileStore() ...
                    .read(pathFile);
            catch ME
                openmebius.infrastructure.model.ModelRepository ...
                    .throwLabelReadError(pathFile, ME);
            end

        end % readLabel

        function writeLabel(~, modelLocation, fileName, fileType, label)

            arguments
                ~
                modelLocation openmebius.domain.model.ModelLocation
                fileName (1, 1) string
                fileType (1, 1) string
                label
            end

            pathFile = modelLocation.labelFile(fileName, fileType);

            try
                openmebius.infrastructure.filesystem.JsonFileStore() ...
                    .writeAtomically(pathFile, label);
            catch
                error( ...
                    "OpenMebius2:ModelRepository:LabelWriteFailed", ...
                    "The data cannot be exported to the file %s.", ...
                    pathFile);
            end

        end % writeLabel

        function image = readPathwayImage(~, modelLocation, fileName, fileType)

            arguments
                ~
                modelLocation openmebius.domain.model.ModelLocation
                fileName (1, 1) string
                fileType (1, 1) string
            end

            pathFile = modelLocation.pathwayFile(fileName, fileType);

            try
                image = imread(pathFile);
            catch
                error( ...
                    "OpenMebius2:ModelRepository:PathwayReadFailed", ...
                    "The pathway image could not be loaded.");
            end

        end % readPathwayImage

        function hash = hashModelFile(~, modelLocation, fileName, fileType, options)

            arguments
                ~
                modelLocation openmebius.domain.model.ModelLocation
                fileName (1, 1) string
                fileType (1, 1) string
                options.Algorithm (1, 1) string = "SHA256"
            end

            hash = openmebius.infrastructure.filesystem.FileHasher ...
                .hashFile( ...
                modelLocation.modelFile(fileName, fileType), ...
                Algorithm = options.Algorithm);

        end % hashModelFile

        function saveModelHashFile(~, modelLocation, fileName, fileType)

            arguments
                ~
                modelLocation openmebius.domain.model.ModelLocation
                fileName (1, 1) string
                fileType (1, 1) string
            end

            openmebius.infrastructure.filesystem.FileHasher.saveHashFile( ...
                modelLocation.modelFile(fileName, fileType));

        end % saveModelHashFile

        function hash = hashFile(~, pathFile, options)

            arguments
                ~
                pathFile (1, 1) string
                options.Algorithm (1, 1) string = "SHA256"
            end

            hash = openmebius.infrastructure.filesystem.FileHasher ...
                .hashFile(pathFile, Algorithm = options.Algorithm);

        end % hashFile

        function saveHashFile(~, pathFile)

            arguments
                ~
                pathFile (1, 1) string
            end

            openmebius.infrastructure.filesystem.FileHasher.saveHashFile(pathFile);

        end % saveHashFile

    end % methods

    methods (Static, Access = private)

        function throwModelSheetReadError(pathFile, cause)

            switch string(cause.identifier)
                case "OpenMebius2:ExcelFileStore:FileNotFound"
                    error( ...
                        "OpenMebius2:ModelRepository:ModelFileNotFound", ...
                        "The file %s does not exist.", ...
                        pathFile);
                case "OpenMebius2:ExcelFileStore:VariableMismatch"
                    error( ...
                        "OpenMebius2:ModelRepository:ModelSheetVariableMismatch", ...
                        "%s", string(cause.message));
                otherwise
                    error( ...
                        "OpenMebius2:ModelRepository:InvalidModelWorkbook", ...
                        "The file %s is not a valid Excel file.", ...
                        pathFile);
            end

        end % throwModelSheetReadError

        function throwLabelReadError(pathFile, cause)

            switch string(cause.identifier)
                case "OpenMebius2:JsonFileStore:FileNotFound"
                    error( ...
                        "OpenMebius2:ModelRepository:LabelFileNotFound", ...
                        "The file %s does not exist.", ...
                        pathFile);
                otherwise
                    error( ...
                        "OpenMebius2:ModelRepository:InvalidLabelJson", ...
                        "The file %s is not a valid JSON file.", ...
                        pathFile);
            end

        end % throwLabelReadError

    end % methods

end % classdef
