classdef RawMSImportService < handle
    % RAWMSIMPORTSERVICE
    % Coordinates raw MS text import and experiment state refresh.

    properties (Access = private)
        RawMSDataRepository
        ExperimentImportService
    end

    methods

        function obj = RawMSImportService(options)

            arguments
                options.RawMSDataRepository = ...
                    openmebius.infrastructure.legacy.LegacyRawMSDataRepository()
                options.ExperimentImportService = ...
                    openmebius.application.experiment.ExperimentImportService()
            end

            obj.RawMSDataRepository = options.RawMSDataRepository;
            obj.ExperimentImportService = options.ExperimentImportService;

        end % constructor

        function result = importShimadzuASCII(obj, rawInput, experimentLocation, model)

            arguments
                obj
                rawInput
                experimentLocation openmebius.domain.experiment.ExperimentLocation
                model
            end

            fragmentNames = obj.fragmentNamesFromModel(model);

            report = obj.RawMSDataRepository.importShimadzuASCII( ...
                rawInput, ...
                experimentLocation, ...
                fragmentNames);

            result = obj.ExperimentImportService.reload( ...
                experimentLocation, ...
                model, ...
                Messages = report.Messages, ...
                ImportedFiles = report.ImportedFiles, ...
                SkippedFiles = report.SkippedFiles);

        end % importShimadzuASCII

    end % methods

    methods (Access = private)

        function fragmentNames = fragmentNamesFromModel(~, model)

            if isempty(model)
                error( ...
                    "OpenMebius2:RawMSImportService:ModelNotLoaded", ...
                    "Model is not loaded. Please load a model before importing MS data.");
            end

            if ~ismethod(model, 'getAtomTable')
                error( ...
                    "OpenMebius2:RawMSImportService:InvalidModel", ...
                    "Model object does not provide getAtomTable().");
            end

            atomTable = model.getAtomTable();

            if ~istable(atomTable)
                error( ...
                    "OpenMebius2:RawMSImportService:InvalidAtomTable", ...
                    "Model getAtomTable() must return a table.");
            end

            fragmentNames = string(atomTable.Properties.RowNames(:));
            fragmentNames = fragmentNames(strlength(fragmentNames) > 0);

            if isempty(fragmentNames)
                error( ...
                    "OpenMebius2:RawMSImportService:NoFragments", ...
                    "Model atom table does not contain MS fragment row names.");
            end

        end % fragmentNamesFromModel

    end % methods (Access = private)

end % classdef
