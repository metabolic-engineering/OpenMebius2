classdef ReportResult < handle
    % REPORTRESULT Builds a self-contained analysis report from public APIs.

    properties (Access = private)
        ResultLocation openmebius.domain.result.ResultLocation
        Model
        Experiments
        ResultData
        ManifestRepository
        OutputPath (1, 1) string = ""
        TemporaryOutputPath (1, 1) string = ""
        Report
        IsBuilt (1, 1) logical = false
    end

    properties (Constant, Access = private)
        Title = "OpenMebius2 Analysis Report"
        Author = "OpenMebius2"
    end

    methods

        function obj = ReportResult(resultInput, model, experiments, result, options)

            arguments
                resultInput
                model
                experiments
                result
                options.OpenAfterBuild (1, 1) logical = true
                options.ManifestRepository = ...
                    openmebius.infrastructure.result.ResultManifestRepository()
            end

            obj.ResultLocation = ...
                openmebius.domain.result.ResultLocation.fromInput(resultInput);
            obj.Model = model;
            obj.Experiments = experiments;
            obj.ResultData = result;
            obj.ManifestRepository = options.ManifestRepository;

            obj.validateInputs();
            obj.build();

            if options.OpenAfterBuild
                obj.view();
            end

        end % constructor

        function build(obj)

            obj.setupReport();
            temporaryFileCleanup = onCleanup(@() ...
                ReportResult.deleteIfExists(obj.TemporaryOutputPath));

            try
                obj.addTitlePage();
                obj.addTableOfContents();
                obj.addOverview();
                obj.addResults();
                obj.addExperimentalData();
                obj.addModelInformation();
                close(obj.Report);
                obj.publishReport();
            catch ME
                obj.closeAfterFailure();
                reportError = MException( ...
                    "OpenMebius2:Report:GenerationFailed", ...
                    "Report generation failed: %s", ...
                    ME.message);
                reportError = addCause(reportError, ME);
                throw(reportError);
            end

            clear temporaryFileCleanup
            obj.IsBuilt = true;

        end % build

        function view(obj)

            if ~obj.IsBuilt || ~isfile(obj.OutputPath)
                error( ...
                    "OpenMebius2:Report:NotBuilt", ...
                    "Report has not been built.");
            end

            rptview(obj.OutputPath);

        end % view

        function outputPath = getOutputPath(obj)

            outputPath = obj.OutputPath;

        end % getOutputPath

    end % methods

    methods (Access = private)

        function validateInputs(obj)

            if ~obj.ResultLocation.directoryExists()
                error( ...
                    "OpenMebius2:Report:ResultDirectoryNotFound", ...
                    "Result directory does not exist: %s", ...
                    obj.ResultLocation.Directory);
            end

            values = {obj.Model, obj.Experiments, obj.ResultData};
            labels = ["Model", "Experiment", "Result"];

            for i = 1:numel(values)

                if isempty(values{i}) || ReportResult.hasErrorState(values{i})
                    error( ...
                        "OpenMebius2:Report:DataUnavailable", ...
                        "%s data is not available.", ...
                        labels(i));
                end

            end

        end % validateInputs

        function setupReport(obj)

            import mlreportgen.report.Report;

            obj.OutputPath = obj.ResultLocation.summaryReportFile();
            obj.TemporaryOutputPath = ...
                string(tempname) + ".html";
            obj.Report = Report(obj.TemporaryOutputPath, "html-file");
            obj.Report.Layout.Landscape = true;
            obj.Report.TitleBarText = obj.Title;
            obj.Report.HTMLHeadExt = char( ...
                openmebius.presentation.report.HtmlReportStyle.headMarkup());

        end % setupReport

        function publishReport(obj)

            if ~isfile(obj.TemporaryOutputPath)
                error( ...
                    "OpenMebius2:Report:OutputNotCreated", ...
                    "The report generator did not create an output file.");
            end

            [isMoved, moveMessage] = movefile( ...
                obj.TemporaryOutputPath, ...
                obj.OutputPath, ...
                'f');

            if ~isMoved
                error( ...
                    "OpenMebius2:Report:PublishFailed", ...
                    "The report could not be published: %s", ...
                    moveMessage);
            end

            obj.TemporaryOutputPath = "";

        end % publishReport

        function closeAfterFailure(obj)

            if isempty(obj.Report)
                return
            end

            try
                close(obj.Report);
            catch
                % Preserve the original report generation error.
            end

        end % closeAfterFailure

        function addTitlePage(obj)

            import mlreportgen.report.TitlePage;

            titlePage = TitlePage;
            titlePage.Title = obj.Title;
            titlePage.Subtitle = ...
                "Version " + System.getCurrentVersion() + ...
                " | Generated " + ReportResult.utcNow();
            titlePage.Author = obj.Author;
            add(obj.Report, titlePage);

        end % addTitlePage

        function addTableOfContents(obj)

            import mlreportgen.report.TableOfContents;

            add(obj.Report, TableOfContents);

        end % addTableOfContents

        function addOverview(obj)

            import mlreportgen.report.Chapter;

            resultIDs = obj.resultIDs();
            experimentNames = obj.experimentNames();
            modelTable = obj.readOrEmpty(@() obj.Model.getModelTable());
            transitionTable = obj.readOrEmpty(@() obj.Model.getMSTable());

            labels = [ ...
                "Generated at (UTC)"; ...
                "OpenMebius2 version"; ...
                "Result directory"; ...
                "Result count"; ...
                "Experiment count"; ...
                "Model reaction count"; ...
                "Carbon transition count"];
            values = [ ...
                ReportResult.utcNow(); ...
                System.getCurrentVersion(); ...
                obj.ResultLocation.Directory; ...
                string(numel(resultIDs)); ...
                string(numel(experimentNames)); ...
                ReportResult.rowCount(modelTable); ...
                ReportResult.rowCount(transitionTable)];
            summary = table(labels, values, ...
                'VariableNames', ["Item", "Value"]);

            chapter = Chapter("Overview");
            obj.addData(chapter, summary);

            if isempty(resultIDs)
                obj.addText(chapter, ...
                    "No HDF5 result files were found in the result directory.");
            end

            add(obj.Report, chapter);

        end % addOverview

        function addResults(obj)

            import mlreportgen.report.Chapter;
            import mlreportgen.report.Section;

            chapter = Chapter("Analysis Results and Reproducibility");
            resultIDs = obj.resultIDs();

            if isempty(resultIDs)
                obj.addText(chapter, "No analysis results are available.");
                add(obj.Report, chapter);
                return
            end

            indexSection = Section("Result Index");
            obj.addData(indexSection, obj.createResultIndex(resultIDs));
            add(chapter, indexSection);

            for i = 1:numel(resultIDs)
                resultID = resultIDs(i);
                resultSection = Section("Result: " + resultID);
                obj.addManifest(resultSection, resultID);
                obj.addDataSection( ...
                    resultSection, ...
                    "Flux Overview", ...
                    @() obj.ResultData.getFluxOverView(resultID));
                obj.addDataSection( ...
                    resultSection, ...
                    "Measured and Estimated MDV", ...
                    @() obj.ResultData.getFluxDetailed(resultID));
                add(chapter, resultSection);
            end

            add(obj.Report, chapter);

        end % addResults

        function index = createResultIndex(obj, resultIDs)

            count = numel(resultIDs);
            status = repmat("unknown", count, 1);
            manifestState = repmat("Missing", count, 1);
            version = repmat("", count, 1);
            modelHash = repmat("", count, 1);
            startedAt = repmat("", count, 1);
            finishedAt = repmat("", count, 1);

            for i = 1:count
                [document, isAvailable, message] = ...
                    obj.readManifest(resultIDs(i));

                if ~isAvailable

                    if message ~= ""
                        manifestState(i) = "Invalid: " + message;
                    end

                    continue
                end

                manifestState(i) = "Available";
                status(i) = ReportResult.nestedString( ...
                    document, ["result", "status"]);
                version(i) = ReportResult.nestedString( ...
                    document, ["software", "openMebius2Version"]);
                modelHash(i) = ReportResult.nestedString( ...
                    document, ["model", "sha256"]);
                startedAt(i) = ReportResult.nestedString( ...
                    document, ["run", "startedAtUtc"]);
                finishedAt(i) = ReportResult.nestedString( ...
                    document, ["run", "finishedAtUtc"]);
            end

            index = table( ...
                resultIDs, ...
                status, ...
                manifestState, ...
                version, ...
                modelHash, ...
                startedAt, ...
                finishedAt, ...
                'VariableNames', [ ...
                "ResultID", "Status", "Manifest", "OpenMebius2", ...
                "ModelSHA256", "StartedAtUTC", "FinishedAtUTC"]);

        end % createResultIndex

        function addManifest(obj, parent, resultID)

            import mlreportgen.report.Section;

            section = Section("Reproducibility Manifest");
            [document, isAvailable, message] = obj.readManifest(resultID);

            if ~isAvailable

                if message == ""
                    obj.addText(section, ...
                        "Manifest is not available. This result predates " + ...
                        "manifest support or was generated externally.");
                else
                    obj.addText(section, ...
                        "Manifest could not be read: " + message);
                end

                add(parent, section);
                return
            end

            obj.addData(section, ReportResult.manifestSummary(document));

            experimentSection = Section("Input Experiments");
            experimentTable = ReportResult.manifestExperiments(document);
            obj.addData(experimentSection, experimentTable);
            add(section, experimentSection);

            configSection = Section("Analysis Configuration");
            config = ReportResult.nestedValue( ...
                document, ["analysis", "config"], struct());
            configTable = ReportResult.flattenValue(config);
            obj.addData(configSection, configTable);
            add(section, configSection);

            add(parent, section);

        end % addManifest

        function [document, isAvailable, message] = readManifest(obj, resultID)

            document = struct();
            isAvailable = false;
            message = "";

            if ~obj.ResultLocation.hasManifestFile(resultID)
                return
            end

            try
                document = obj.ManifestRepository.read( ...
                    obj.ResultLocation, ...
                    resultID);
                isAvailable = true;
            catch ME
                message = string(ME.message);
            end

        end % readManifest

        function addExperimentalData(obj)

            import mlreportgen.report.Chapter;
            import mlreportgen.report.Section;

            chapter = Chapter("Experimental Data");
            obj.addDataSection( ...
                chapter, ...
                "Experiment Overview", ...
                @() obj.Experiments.getInfoTable());
            obj.addDataSection( ...
                chapter, ...
                "Tracer Configuration", ...
                @() obj.Experiments.getTracerTable());
            obj.addDataSection( ...
                chapter, ...
                "Uptake and Secretion", ...
                @() obj.Experiments.getUptakeTable());

            names = obj.experimentNames();

            for i = 1:numel(names)
                experimentName = names(i);
                section = Section("Experiment: " + experimentName);
                obj.addDataSection( ...
                    section, ...
                    "Mass Spectrometry Data", ...
                    @() obj.Experiments.getMSTable(experimentName));
                obj.addDataSection( ...
                    section, ...
                    "Normalized Mass Spectrometry Data", ...
                    @() obj.Experiments.getMSNormalizedTable(experimentName));
                obj.addDataSection( ...
                    section, ...
                    "Mass Distribution Vectors", ...
                    @() obj.Experiments.getMDVTable(experimentName));
                add(chapter, section);
            end

            add(obj.Report, chapter);

        end % addExperimentalData

        function addModelInformation(obj)

            import mlreportgen.report.Chapter;

            chapter = Chapter("Model Information");
            obj.addDataSection( ...
                chapter, "Model Overview", @() obj.Model.getInfoTable());
            obj.addDataSection( ...
                chapter, "Metabolic Network", @() obj.Model.getModelTable());
            obj.addDataSection( ...
                chapter, "Carbon Transition", @() obj.Model.getMSTable());
            obj.addDataSection( ...
                chapter, "Biomass", @() obj.Model.getBiomassTable());
            obj.addDataSection( ...
                chapter, "Molecular Composition", @() obj.Model.getAtomTable());
            obj.addDataSection( ...
                chapter, "Stoichiometric Matrix", @() obj.Model.getSBefore());
            add(obj.Report, chapter);

        end % addModelInformation

        function addDataSection(obj, parent, title, provider)

            import mlreportgen.report.Section;

            section = Section(title);

            try
                data = provider();
                obj.addData(section, data);
            catch ME
                obj.addText(section, "Data could not be loaded: " + ME.message);
            end

            add(parent, section);

        end % addDataSection

        function addData(obj, parent, data)

            import mlreportgen.dom.CustomAttribute;
            import mlreportgen.dom.FormalTable;

            if isempty(data)
                obj.addText(parent, "No data available.");
                return
            end

            try
                [tableHeader, tableBody] = ...
                    openmebius.presentation.report.ReportTableFormatter ...
                    .format(data);

                if isempty(tableHeader)
                    reportTable = FormalTable(tableBody);
                else
                    reportTable = FormalTable(tableHeader, tableBody);
                end

                reportTable.CustomAttributes = ...
                    CustomAttribute('class', 'openmebius-report-table');
                reportTable.IsSortable = ReportResult.rowCount(data) ~= "1";
                add(parent, reportTable);
            catch ME
                obj.addText(parent, ...
                    "Data could not be rendered: " + ME.message);
            end

        end % addData

        function addText(~, parent, value)

            import mlreportgen.dom.CustomAttribute;
            import mlreportgen.dom.Paragraph;

            paragraph = Paragraph(char(string(value)));
            paragraph.CustomAttributes = ...
                CustomAttribute('class', 'openmebius-report-note');
            add(parent, paragraph);

        end % addText

        function IDs = resultIDs(obj)

            IDs = obj.ResultLocation.resultIds();

        end % resultIDs

        function names = experimentNames(obj)

            try
                names = string(obj.Experiments.getExpList());
                names = names(:);
                names = names(strlength(names) > 0);
            catch
                names = strings(0, 1);
            end

        end % experimentNames

        function value = readOrEmpty(~, provider)

            try
                value = provider();
            catch
                value = [];
            end

        end % readOrEmpty

    end % methods (Access = private)

    methods (Static, Access = private)

        function tf = hasErrorState(value)

            tf = false;

            if isstruct(value) && isfield(value, "isError")
                tf = logical(value.isError);
            elseif isobject(value) && isprop(value, "isError")
                tf = logical(value.isError);
            end

        end % hasErrorState

        function timestamp = utcNow()

            timestamp = string(datetime( ...
                "now", ...
                "TimeZone", "UTC", ...
                "Format", "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"));

        end % utcNow

        function count = rowCount(value)

            if isempty(value)
                count = "0";
            elseif istable(value) || istimetable(value)
                count = string(height(value));
            else
                count = string(size(value, 1));
            end

        end % rowCount

        function value = nestedValue(data, path, defaultValue)

            value = data;

            for i = 1:numel(path)
                fieldName = char(path(i));

                if ~isstruct(value) || ~isscalar(value) || ...
                        ~isfield(value, fieldName)
                    value = defaultValue;
                    return
                end

                value = value.(fieldName);
            end

        end % nestedValue

        function value = nestedString(data, path)

            value = ReportResult.formatValue( ...
                ReportResult.nestedValue(data, path, ""));

        end % nestedString

        function summary = manifestSummary(document)

            labels = [ ...
                "Manifest schema version"; ...
                "Batch ID"; ...
                "Content hash"; ...
                "Content hash version"; ...
                "Result status"; ...
                "Result file"; ...
                "Result SHA-256"; ...
                "Result size (bytes)"; ...
                "OpenMebius2 version"; ...
                "MATLAB release"; ...
                "MATLAB version"; ...
                "Model file"; ...
                "Model SHA-256"; ...
                "Random generator"; ...
                "Random seed"; ...
                "Started at (UTC)"; ...
                "Finished at (UTC)"; ...
                "Error"; ...
                "Canceled"];
            paths = { ...
                "schemaVersion"; ...
                ["batch", "id"]; ...
                ["batch", "contentHash"]; ...
                ["batch", "contentHashVersion"]; ...
                ["result", "status"]; ...
                ["result", "file"]; ...
                ["result", "sha256"]; ...
                ["result", "sizeBytes"]; ...
                ["software", "openMebius2Version"]; ...
                ["software", "matlabRelease"]; ...
                ["software", "matlabVersion"]; ...
                ["model", "fileName"]; ...
                ["model", "sha256"]; ...
                ["random", "type"]; ...
                ["random", "seed"]; ...
                ["run", "startedAtUtc"]; ...
                ["run", "finishedAtUtc"]; ...
                ["run", "isError"]; ...
                ["run", "isCanceled"]};
            values = strings(numel(paths), 1);

            for i = 1:numel(paths)
                values(i) = ReportResult.formatValue( ...
                    ReportResult.nestedValue(document, paths{i}, ""));
            end

            summary = table(labels, values, ...
                'VariableNames', ["Item", "Value"]);

        end % manifestSummary

        function experimentTable = manifestExperiments(document)

            experiments = ReportResult.nestedValue( ...
                document, "experiments", struct.empty(0, 1));

            if isempty(experiments) || ~isstruct(experiments)
                experimentTable = table();
                return
            end

            count = numel(experiments);
            names = strings(count, 1);
            fileNames = strings(count, 1);
            hashes = strings(count, 1);

            for i = 1:count
                names(i) = ReportResult.nestedString( ...
                    experiments(i), "name");
                fileNames(i) = ReportResult.nestedString( ...
                    experiments(i), "fileName");
                hashes(i) = ReportResult.nestedString( ...
                    experiments(i), "sha256");
            end

            experimentTable = table( ...
                names, ...
                fileNames, ...
                hashes, ...
                'VariableNames', ["Experiment", "File", "SHA256"]);

        end % manifestExperiments

        function flattened = flattenValue(value)

            [paths, values] = ReportResult.flattenValueRecursive(value, "");

            if isempty(paths)
                flattened = table();
                return
            end

            flattened = table(paths, values, ...
                'VariableNames', ["Setting", "Value"]);

        end % flattenValue

        function [paths, values] = flattenValueRecursive(value, prefix)

            paths = strings(0, 1);
            values = strings(0, 1);

            if isstruct(value) && isscalar(value)
                fields = string(fieldnames(value));

                if isempty(fields)
                    return
                end

                for i = 1:numel(fields)

                    if prefix == ""
                        childPrefix = fields(i);
                    else
                        childPrefix = prefix + "." + fields(i);
                    end

                    [childPaths, childValues] = ...
                        ReportResult.flattenValueRecursive( ...
                        value.(char(fields(i))), ...
                        childPrefix);
                    paths = [paths; childPaths]; %#ok<AGROW>
                    values = [values; childValues]; %#ok<AGROW>
                end

                return
            end

            paths = prefix;
            values = ReportResult.formatValue(value);

        end % flattenValueRecursive

        function textValue = formatValue(value)

            if isempty(value)
                textValue = "";
                return
            end

            if ischar(value)
                textValue = string(value);
                return
            end

            if isstring(value) || iscategorical(value)
                stringValue = string(value(:));
                textValue = strjoin(stringValue, ", ");
                return
            end

            if isnumeric(value) || islogical(value) || isdatetime(value)

                if isscalar(value)
                    textValue = string(value);
                elseif numel(value) <= 12
                    textValue = "[" + strjoin(string(value(:))', ", ") + "]";
                else
                    textValue = string(jsonencode(value));
                end

                return
            end

            try
                textValue = string(jsonencode(value));
            catch
                textValue = "<" + string(class(value)) + ">";
            end

        end % formatValue

        function deleteIfExists(pathFile)

            if pathFile ~= "" && isfile(pathFile)
                delete(pathFile);
            end

        end % deleteIfExists

    end % methods (Static, Access = private)

end % classdef
