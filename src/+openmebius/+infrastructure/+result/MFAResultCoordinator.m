classdef MFAResultCoordinator
    % MFARESULTCOORDINATOR
    % Coordinates in-memory MFA result state and checkpoint persistence.

    properties (SetAccess = private)
        InputSnapshotWriter
        ResultCheckpointWriter
        NextLabelCheckpointWriter
        HDF5FilePath (1, 1) string
        IsExport (1, 1) logical
    end

    methods

        function obj = MFAResultCoordinator(options)

            arguments
                options.InputSnapshotWriter = ...
                    openmebius.infrastructure.result.MFAInputSnapshotWriter()
                options.ResultCheckpointWriter = ...
                    openmebius.infrastructure.result.MFAResultCheckpointWriter()
                options.NextLabelCheckpointWriter = ...
                    openmebius.infrastructure.result ...
                    .NextLabelResultCheckpointWriter()
                options.HDF5FilePath (1, 1) string = ""
                options.IsExport (1, 1) logical = true
            end

            obj.InputSnapshotWriter = options.InputSnapshotWriter;
            obj.ResultCheckpointWriter = ...
                options.ResultCheckpointWriter;
            obj.NextLabelCheckpointWriter = ...
                options.NextLabelCheckpointWriter;
            obj.HDF5FilePath = options.HDF5FilePath;
            obj.IsExport = options.IsExport;

        end % constructor

        function [result, status, isSuccess, message] = writeGeneral( ...
                obj, result, status, resultID, experimentalMDV, ...
                fragmentList, fragmentMask)

            result = obj.normalizeResult(result);
            checkpoint = obj.InputSnapshotWriter ...
                .createGeneralCheckpoint( ...
                status, resultID, experimentalMDV, ...
                fragmentList, fragmentMask);
            result.status = checkpoint.Value.status;
            result.ID = checkpoint.Value.ID;
            result.MDVExp = checkpoint.Value.MDVExp;
            result.MDVFragList = checkpoint.Value.MDVFragList;
            result.MDVFragMask = checkpoint.Value.MDVFragMask;
            [isSuccess, message] = obj.noWriteResult();

            if obj.IsExport
                [isSuccess, message] = ...
                    obj.InputSnapshotWriter.writeGeneral( ...
                    obj.HDF5FilePath, checkpoint);
            end

        end % writeGeneral

        function [result, status, isSuccess, message] = writeModel( ...
                obj, result, status, modelTable, reversibleModelTable)

            result = obj.normalizeResult(result);
            [isSuccess, message] = obj.noWriteResult();

            if ~obj.IsExport
                return;
            end

            checkpoint = obj.InputSnapshotWriter.createModelCheckpoint( ...
                modelTable, reversibleModelTable);
            result.model = checkpoint.Value;
            [isSuccess, message] = obj.InputSnapshotWriter.writeModel( ...
                obj.HDF5FilePath, checkpoint);

        end % writeModel

        function [result, status, isSuccess, message] = ...
                writeFluxVariability( ...
                obj, result, status, lowerBounds, upperBounds, ...
                reversibleReactionIndices)

            result = obj.normalizeResult(result);
            checkpoint = obj.ResultCheckpointWriter ...
                .createFluxVariabilityCheckpoint( ...
                lowerBounds, upperBounds, reversibleReactionIndices);
            result.fluxVariability = checkpoint.Value;
            result.status = status;
            [isSuccess, message] = obj.noWriteResult();

            if obj.IsExport
                [isSuccess, message] = obj.ResultCheckpointWriter ...
                    .writeFluxVariability( ...
                    obj.HDF5FilePath, checkpoint, status);
            end

        end % writeFluxVariability

        function [result, status, isSuccess, message] = ...
                writeInitialFlux( ...
                obj, result, status, flux, rightHandSide, ...
                objectiveValues, reversibleReactionIndices)

            result = obj.normalizeResult(result);
            checkpoint = obj.ResultCheckpointWriter ...
                .createInitialFluxCheckpoint( ...
                flux, rightHandSide, objectiveValues, ...
                reversibleReactionIndices);
            result.initialFlux = checkpoint.Value;
            status(1) = 1;
            result.status = status;
            [isSuccess, message] = obj.noWriteResult();

            if obj.IsExport
                [isSuccess, message] = obj.ResultCheckpointWriter ...
                    .writeInitialFlux( ...
                    obj.HDF5FilePath, checkpoint, status);
            end

        end % writeInitialFlux

        function [result, status, isSuccess, message] = writeSummary( ...
                obj, result, status, objectiveValues, order, threshold)

            result = obj.normalizeResult(result);
            status(2) = 1;
            result.RSS = objectiveValues;
            result.RSSIdx = order;
            result.status = status;
            result.threshold = threshold;
            [isSuccess, message] = obj.noWriteResult();

            if obj.IsExport
                [isSuccess, message] = ...
                    obj.ResultCheckpointWriter.writeSummary( ...
                    obj.HDF5FilePath, objectiveValues, order, ...
                    status, threshold);
            end

        end % writeSummary

        function [result, status, isSuccess, message] = ...
                writeMonteCarloConfidenceInterval( ...
                obj, result, status, lowerBounds, upperBounds, ...
                confidenceIntervalConfig, output)

            result = obj.normalizeResult(result);
            [isSuccess, message] = obj.noWriteResult();

            if ~obj.IsExport
                return;
            end

            checkpoint = obj.ResultCheckpointWriter ...
                .createMonteCarloConfidenceIntervalCheckpoint( ...
                lowerBounds, upperBounds, confidenceIntervalConfig, output);
            status(3) = 1;
            result.status = status;
            result.CI = checkpoint.Value;
            result.fluxLB = checkpoint.FinalFluxLB;
            result.fluxUB = checkpoint.FinalFluxUB;

            if string(checkpoint.Value.algorithm) ~= "Monte Carlo"
                return;
            end

            [isSuccess, message] = obj.ResultCheckpointWriter ...
                .writeMonteCarloConfidenceInterval( ...
                obj.HDF5FilePath, checkpoint, status);

        end % writeMonteCarloConfidenceInterval

        function [result, status, isSuccess, message] = writeIteration( ...
                obj, result, status, iteration, iterationResult, ...
                reversibleReactionIndices)

            result = obj.normalizeResult(result);
            checkpoint = obj.ResultCheckpointWriter ...
                .createIterationCheckpoint( ...
                iteration, iterationResult, reversibleReactionIndices);
            result.(checkpoint.FieldName) = checkpoint.Value;
            result.status = status;
            [isSuccess, message] = obj.noWriteResult();

            if obj.IsExport
                [isSuccess, message] = ...
                    obj.ResultCheckpointWriter.writeIteration( ...
                    obj.HDF5FilePath, checkpoint);
            end

        end % writeIteration

        function [isSuccess, message] = writeSuggestionTable( ...
                obj, suggestionData, columnNames)

            [isSuccess, message] = obj.noWriteResult();

            if ~obj.IsExport
                return;
            end

            checkpoint = obj.NextLabelCheckpointWriter ...
                .createSuggestionTableCheckpoint( ...
                suggestionData, columnNames);
            [isSuccess, message] = obj.NextLabelCheckpointWriter ...
                .writeSuggestionTable(obj.HDF5FilePath, checkpoint);

        end % writeSuggestionTable

        function [result, status, isSuccess, message] = ...
                writeNextLabelInitialFlux( ...
                obj, result, status, pattern, flux, rightHandSide, ...
                objectiveValues, reversibleReactionIndices)

            result = obj.normalizeResult(result);
            [isSuccess, message] = obj.noWriteResult();

            if ~obj.IsExport
                return;
            end

            checkpoint = obj.NextLabelCheckpointWriter ...
                .createInitialFluxCheckpoint( ...
                pattern, flux, rightHandSide, objectiveValues, ...
                reversibleReactionIndices);
            result = obj.mergeNextLabelCheckpoint(result, checkpoint);
            result.status = status;
            [isSuccess, message] = obj.NextLabelCheckpointWriter ...
                .writeInitialFlux(obj.HDF5FilePath, checkpoint);

        end % writeNextLabelInitialFlux

        function [result, status, isSuccess, message] = ...
                writeNextLabelConfidenceInterval( ...
                obj, result, status, pattern, lowerBounds, upperBounds)

            result = obj.normalizeResult(result);
            [isSuccess, message] = obj.noWriteResult();

            if ~obj.IsExport
                return;
            end

            checkpoint = obj.NextLabelCheckpointWriter ...
                .createConfidenceIntervalCheckpoint( ...
                pattern, lowerBounds, upperBounds);
            result = obj.mergeNextLabelCheckpoint(result, checkpoint);
            result.status = status;
            [isSuccess, message] = obj.NextLabelCheckpointWriter ...
                .writeConfidenceInterval(obj.HDF5FilePath, checkpoint);

        end % writeNextLabelConfidenceInterval

    end % methods

    methods (Static, Access = private)

        function result = normalizeResult(result)

            if isempty(result)
                result = struct;
            elseif ~isstruct(result) || ~isscalar(result)
                error( ...
                    "OpenMebius2:MFAResultCoordinator:InvalidResult", ...
                    "The MFA result state must be a scalar struct.");
            end

        end % normalizeResult

        function result = mergeNextLabelCheckpoint(result, checkpoint)

            if ~isfield(result, 'nextLabelPattern') || ...
                    ~isstruct(result.nextLabelPattern)
                result.nextLabelPattern = struct;
            end

            fieldName = char(checkpoint.FieldName);

            if isfield(result.nextLabelPattern, fieldName)
                value = result.nextLabelPattern.(fieldName);
            else
                value = struct;
            end

            sourceFields = fieldnames(checkpoint.Value);

            for fieldIndex = 1:numel(sourceFields)
                sourceField = sourceFields{fieldIndex};
                value.(sourceField) = checkpoint.Value.(sourceField);
            end

            result.nextLabelPattern.(fieldName) = value;

        end % mergeNextLabelCheckpoint

        function [isSuccess, message] = noWriteResult()

            isSuccess = true;
            message = "";

        end % noWriteResult

    end % methods (Static, Access = private)

end % classdef
