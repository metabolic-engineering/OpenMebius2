classdef IOExp < Status

    properties

        fileTypeExperiment (1, 1) string {mustBeMember(fileTypeExperiment, ["xlsx", "csv"])} = "xlsx";
        pathExp (1, 1) string = "";
        pathModel (1, 1) string = "";

        tableInfo table;
        tableSubstrate table;
        tableMS table;
        tableMSNormalized table;
        tableMDV table;
        tableMDVBiomass table;
        tableEnrichment table;

        errMDV logical
        errEnrichment logical;

    end

    properties (Access = private)

        strTableList string = ...
            ["tableInfo", ...
             "tableSubstrate", ...
             "tableMS", ...
             "tableMSNormalized", ...
             "tableMDV", ...
             "tableMDVBiomass", ...
             "tableEnrichment", ...
         ];
        strTableSheetName string = ...
            ["info", "substrate", "MS", "MS (Normalized)", "MDV", "MDV (biomass)", "Enrichment"];
        tableReadRowName (1, 7) logical = ...
            [false, true, true, true, true, true, true];
        tableVariableNames struct = struct;
        tableVariableTypes struct = struct;
        ExperimentRepository

    end % properties

    methods

        function obj = IOExp(pathExp, options)

            arguments
                pathExp (1, 1) string;
                options.type (1, 1) string {mustBeMember(options.type, ["xlsx", "csv"])} = "xlsx";
                options.importMSOnly (1, 1) logical = false;
                options.loadOnly (1, 1) logical = false;
                options.ExperimentRepository = ...
                    openmebius.infrastructure.experiment.ExperimentRepository();
            end % constructor

            % pathExpからファイル名を除去する
            [dirExp, ~, ~] = fileparts(pathExp);

            obj.ExperimentRepository = options.ExperimentRepository;

            experimentLocation = ...
                openmebius.domain.experiment.ExperimentLocation ...
                .fromDirectory(dirExp);

            try
                obj.ExperimentRepository.assertExperimentDirectory( ...
                    experimentLocation);
            catch
                obj.isError = true;
                updateMsg(obj, ...
                    "The directory " + string(dirExp) + ...
                    " does not exist.", ...
                    "Error", ...
                    obj.logLevel);
                return
            end

            updateMsg(obj, ...
                "The directory " + string(dirExp) + " exists.", ...
                "Info", ...
                obj.logLevel);

            if obj.isError
                return;
            end

            obj.pathExp = pathExp;

            obj.setupTableVariableNames();
            obj.setupTableVariableTypes();

            if options.loadOnly
                return;
            end

            if options.importMSOnly
                loadMSData(obj, "MS");
                return;
            end

            obj.loadExcelData();

        end % constructor

        function vars = getDefualtVariables(obj, type)
            % GETDEFUALTVARIABLES Get default variables for the experiment.
            %
            % Parameters:
            % -----------
            % obj: IOExp
            %     The current object instance.
            % type: string
            %     The type of variable to get. Options are "info", "substrate", "MS".
            %
            % Returns:
            % --------
            % vars: string
            %     The default variable names for the specified type.

            arguments
                obj;
                type (1, 1) string {mustBeMember(type, ["info", "substrate"])};
            end

            switch type
                case "info"
                    vars = obj.tableVariableNames.tableInfo;
                case "substrate"
                    vars = obj.tableVariableNames.tableSubstrate;
            end % switch

        end % getDefualtVariables

        function vars = getDefualtVariableTypes(obj, type)
            % GETDEFUALTVARIABLETYPES Get default variable types for the experiment.
            %
            % Parameters:
            % -----------
            % obj: IOExp
            %     The current object instance.
            % type: string
            %     The type of variable to get. Options are "info", "substrate", "MS".
            %
            % Returns:
            % --------
            % vars: string
            %     The default variable types for the specified type.

            arguments
                obj;
                type (1, 1) string {mustBeMember(type, ["info", "substrate"])};
            end

            switch type
                case "info"
                    vars = obj.tableVariableTypes.tableInfo;
                case "substrate"
                    vars = obj.tableVariableTypes.tableSubstrate;
            end % switch

        end % getDefualtVariableTypes

        function loadExcelData(obj)

            try
                obj.tableInfo = obj.ExperimentRepository.readWorkbookSheet( ...
                obj.pathExp, ...
                "info", ...
                ReadRowNames = obj.tableReadRowName(1), ...
                RefVariableNames = obj.tableVariableNames.tableInfo, ...
                RefTypes = obj.tableVariableTypes.tableInfo);
                reset(obj);
                updateMsg(obj, ...
                    obj.pathExp + "/info is successfully imported.", ...
                    "Info", obj.logLevel);
            catch ME
                obj.isError = true;
                updateMsg(obj, string(ME.message), "Error", obj.logLevel);
                createNewExpSheetInfo(obj);
                reset(obj);
                updateMsg(obj, "Failed to load info data from the Excel file. A new sheet has been created.", "Warning", obj.logLevel);
            end

            try
                obj.tableSubstrate = obj.ExperimentRepository.readWorkbookSheet( ...
                obj.pathExp, ...
                "substrate", ...
                ReadRowNames = obj.tableReadRowName(2), ...
                RefVariableNames = obj.tableVariableNames.tableSubstrate, ...
                RefTypes = obj.tableVariableTypes.tableSubstrate);
                reset(obj);
                updateMsg(obj, ...
                    obj.pathExp + "/substrate is successfully imported.", ...
                    "Info", obj.logLevel);
            catch ME
                obj.isError = true;
                updateMsg(obj, string(ME.message), "Error", obj.logLevel);
                createNewExpSheetSubstrate(obj);
                reset(obj);
                updateMsg(obj, "Failed to load substrate data from the Excel file. A new sheet has been created.", "Warning", obj.logLevel);
            end

            try
                obj.tableMS = obj.ExperimentRepository.readWorkbookSheet( ...
                obj.pathExp, ...
                "MS", ...
                ReadRowNames = obj.tableReadRowName(3), ...
                CheckVariable = false);
                reset(obj);
                updateMsg(obj, ...
                    obj.pathExp + "/MS is successfully imported.", ...
                    "Info", obj.logLevel);
            catch ME
                obj.isError = true;
                updateMsg(obj, string(ME.message), "Error", obj.logLevel);
                obj.tableMS = table();
                reset(obj);
                updateMsg(obj, ...
                    "The MS sheet was not loaded. Stored MDV-derived sheets will still be checked.", ...
                    "Warning", obj.logLevel);
            end

            loadDerivedExcelData(obj);

        end % loadExcelData

        function loadMSData(obj, sheetName, options)

            arguments
                obj;
                sheetName (1, 1) string;
                options.type (1, 1) string {mustBeMember(options.type, ["xlsx", "csv"])} = "xlsx";
            end

            createNewExpSheetInfo(obj);
            createNewExpSheetSubstrate(obj);

            try
                obj.tableMS = obj.ExperimentRepository.readWorkbookSheet( ...
                    obj.pathExp, ...
                    sheetName, ...
                    ReadRowNames = obj.tableReadRowName(3), ...
                    CheckVariable = false);
                reset(obj);
                updateMsg(obj, ...
                    obj.pathExp + "/" + sheetName + ...
                    " is successfully imported.", ...
                    "Info", obj.logLevel);
            catch ME
                obj.isError = true;
                updateMsg(obj, string(ME.message), "Error", obj.logLevel);
                updateMsg(obj, "Failed to load MS data from the Excel file.", "Error", obj.logLevel);
                return;
            end

        end % loadMSData

        function createNewExpSheetInfo(obj)
            % CREATENEWEXPSHEETINFO Create a new experiment sheet info table.
            %
            % Parameters:
            % -----------
            % obj: IOExp
            %     The current object instance.
            %
            % Returns:
            % --------
            % None

            obj.tableInfo = table('Size', [1, 3], ...
                'VariableNames', obj.tableVariableNames.tableInfo, ...
                'VariableTypes', ["double", "double", "double"]);

        end % createNewExpSheetInfo

        function createNewExpSheetSubstrate(obj)
            % CREATENEWEXPSHEETSUBSTRATE Create a new experiment sheet substrate table.
            %
            % Parameters:
            % -----------
            % obj: IOExp
            %     The current object instance.
            %
            % Returns:
            % --------
            % None

            obj.tableSubstrate = table('Size', [0, 2], ...
                'VariableNames', obj.tableVariableNames.tableSubstrate, ...
                'VariableTypes', ["double", "string"]);

        end % createNewExpSheetSubstrate

        function createNewExpSheetMS(obj)
            % 未完成

            obj.tableMS = table();

            if ~obj.isModelLoaded
                return;
            end

        end % createNewExpSheetMS

        function saveExcelData(obj, options)
            % SAVEEXCELDATA Save the experiment data to an Excel file.
            %
            % Parameters:
            % -----------
            % obj: IOExp
            %     The current object instance.
            % options: struct
            %     A structure containing options for saving the data.
            %     - type: string (default: "xlsx")
            %         The type of file to save. Options are "xlsx" or "csv".
            %
            % Returns:
            % --------
            % None

            arguments
                obj;
                options.type (1, 1) string {mustBeMember(options.type, ["xlsx", "csv"])} = "xlsx";
            end % constructor

            if obj.isError
                return;
            end

            for i = 1:length(obj.strTableList)

                tableName = obj.strTableList(i);
                sheetName = obj.strTableSheetName(i);

                switch options.type
                    case "xlsx"
                        [isSuccess, msg] = ...
                            obj.ExperimentRepository.writeWorkbookSheet( ...
                            obj.pathExp, ...
                            obj.(tableName), ...
                            sheetName, ...
                            WriteRowNames = obj.tableReadRowName(i) ...
                        );

                        if ~isSuccess
                            obj.isError = true;
                            updateMsg(obj, string(msg), "Error", obj.logLevel);
                            return
                        end
                    case "csv"
                        % Unimplemented: CSV export
                        continue;
                end

            end % for i

        end % saveExcelData

    end % methods

    methods (Access = private)

        function loadDerivedExcelData(obj)
            % LOADDERIVEDEXCELDATA Load optional MDV-derived sheets.

            derivedTableIdx = 4:length(obj.strTableList);

            for i = derivedTableIdx

                tableName = obj.strTableList(i);
                sheetName = obj.strTableSheetName(i);

                obj.(tableName) = importOptionalExcelSheet( ...
                    obj, ...
                    sheetName, ...
                    obj.tableReadRowName(i) ...
                );

            end % for i

        end % loadDerivedExcelData

        function data = importOptionalExcelSheet(obj, sheetName, readRowNames)

            arguments
                obj
                sheetName (1, 1) string
                readRowNames (1, 1) logical
            end

            aliases = getOptionalSheetAliases(obj, sheetName);

            try
                data = obj.ExperimentRepository.readOptionalWorkbookSheet( ...
                    obj.pathExp, ...
                    sheetName, ...
                    aliases, ...
                    ReadRowNames = readRowNames, ...
                    ReadVariableNames = true);
                obj.reset();
            catch
                data = table();
                obj.reset();
            end

        end % importOptionalExcelSheet

        function aliases = getOptionalSheetAliases(~, preferredSheetName)
            % GETOPTIONALSHEETALIASES Return accepted aliases for derived
            % experiment sheets.

            switch preferredSheetName
                case "MS (Normalized)"
                    aliases = [ ...
                                   "MS (Normalized)", ...
                                   "MS Normalized", ...
                                   "MS normalized data", ...
                                   "MS normarized data", ...
                                   "MSNormalized", ...
                                   "MS_Normalized", ...
                                   "正規化MS" ...
                               ];
                case "MDV"
                    aliases = [ ...
                                   "MDV", ...
                                   "MDV (Mass distribution vectors)", ...
                                   "Mass distribution vectors", ...
                                   "Mass distribution vector" ...
                               ];
                case "MDV (biomass)"
                    aliases = [ ...
                                   "MDV (biomass)", ...
                                   "MDV (Biomass)", ...
                                   "MDV biomass", ...
                                   "MDVBiomass", ...
                                   "MDV_Biomass", ...
                                   "Biomass corrected MDV", ...
                                   "Biomass-corrected MDV", ...
                                   "Biomass-corrected mass distribution vectors", ...
                                   "Corrected MDV", ...
                                   "corrected MDV", ...
                                   "補正済みMDV", ...
                                   "バイオマス補正MDV" ...
                               ];
                case "Enrichment"
                    aliases = [ ...
                                   "Enrichment", ...
                                   "Atom enrichment", ...
                                   "Enrichment data", ...
                                   "濃縮率" ...
                               ];
                otherwise
                    aliases = preferredSheetName;
            end % switch

            aliases = unique([preferredSheetName aliases], "stable");

        end % getOptionalSheetAliases

        function setupTableVariableNames(obj)

            obj.tableVariableNames.tableInfo = ...
                ["mu", "ODi", "ODf"];
            obj.tableVariableNames.tableSubstrate = ...
                ["Uptake", "Label"];

        end

        function setupTableVariableTypes(obj)

            obj.tableVariableTypes.tableInfo = ...
                ["double", "double", "double"];
            obj.tableVariableTypes.tableSubstrate = ...
                ["double", "string"];

        end

    end % methods

end % classdef
