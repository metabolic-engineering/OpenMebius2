classdef RawMSDataRepository < handle
    % RAWMSDATAREPOSITORY Imports Shimadzu ASCII files as workbooks.

    properties (Access = private)
        Parser
        Mapper
        Exporter
    end

    methods

        function obj = RawMSDataRepository(options)

            arguments
                options.Parser = openmebius.infrastructure.experiment ...
                    .ShimadzuAsciiParser()
                options.Mapper = openmebius.infrastructure.experiment ...
                    .RawMSFragmentMapper()
                options.Exporter = openmebius.infrastructure.experiment ...
                    .RawMSWorkbookExporter()
            end

            obj.Parser = options.Parser;
            obj.Mapper = options.Mapper;
            obj.Exporter = options.Exporter;

        end

        function report = importShimadzuASCII( ...
                obj, rawInput, experimentInput, fragmentNames)

            rawLocation = openmebius.domain.raw.RawDataLocation ...
                .fromInput(rawInput);
            experimentLocation = openmebius.domain.experiment ...
                .ExperimentLocation.fromInput(experimentInput);
            obj.validateInputs( ...
                rawLocation, experimentLocation, fragmentNames);
            textFiles = rawLocation.textFiles();
            report = struct( ...
                ImportedFiles = strings(0, 1), ...
                SkippedFiles = strings(0, 1), ...
                Messages = strings(0, 1));
            failures = strings(0, 1);

            for fileIndex = 1:numel(textFiles)
                sourceName = string(textFiles(fileIndex));
                sourceFile = rawLocation.textFile(sourceName);

                try
                    data = obj.Parser.parse(sourceFile);
                    msTable = obj.Mapper.map( ...
                        data(:, ["Name", "Area"]), ...
                        string(fragmentNames(:)));
                    [~, name] = fileparts(sourceName);
                    workbookName = string(name) + ".xlsx";
                    workbookFile = experimentLocation ...
                        .workbookFile(workbookName);
                    obj.Exporter.export(msTable, workbookFile);
                    report.ImportedFiles(end + 1, 1) = workbookName;
                    report.Messages(end + 1, 1) = ...
                        "Raw MS data imported successfully: " + workbookName;
                catch exception
                    failures(end + 1, 1) = ...
                        sourceName + ": " + string(exception.message); %#ok<AGROW>
                end

            end

            if ~isempty(failures)
                error( ...
                    "OpenMebius2:RawMSDataRepository:ImportFailed", ...
                    "%s", join(failures, newline));
            end

        end

    end

    methods (Static, Access = private)

        function validateInputs(rawLocation, experimentLocation, fragmentNames)

            if ~isfolder(rawLocation.Directory)
                error( ...
                    "OpenMebius2:RawMSDataRepository:RawDirectoryNotFound", ...
                    "Raw MS data directory does not exist: %s", ...
                    rawLocation.Directory);
            end

            if ~isfolder(experimentLocation.Directory)
                error( ...
                    "OpenMebius2:RawMSDataRepository:ExperimentDirectoryNotFound", ...
                    "Experiment directory does not exist: %s", ...
                    experimentLocation.Directory);
            end

            if isempty(rawLocation.textFiles())
                error( ...
                    "OpenMebius2:RawMSDataRepository:NoTextFiles", ...
                    "No raw MS text files were found in: %s", ...
                    rawLocation.Directory);
            end

            if ~any(strlength(string(fragmentNames(:))) > 0)
                error( ...
                    "OpenMebius2:RawMSDataRepository:NoFragments", ...
                "No MS fragment names were provided for raw MS import.");
            end

        end

    end

end
