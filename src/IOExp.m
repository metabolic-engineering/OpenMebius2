classdef IOExp < IO

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

    end % properties

    methods

        function obj = IOExp(pathExp, options)

            arguments
                pathExp (1, 1) string;
                options.type (1, 1) string {mustBeMember(options.type, ["xlsx", "csv"])} = "xlsx";
                options.importMSOnly (1, 1) logical = false;
                options.loadOnly (1, 1) logical = false;
            end % constructor

            % pathExpからファイル名を除去する
            [dirExp, ~, ~] = fileparts(pathExp);

            obj = obj@IO(dirExp);

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

            obj.tableInfo = importExcelFile( ...
                obj, ...
                obj.pathExp, ...
                "info", ...
                ReadRowNames = obj.tableReadRowName(1), ...
                refVariableNames = obj.tableVariableNames.tableInfo, ...
                refTypes = obj.tableVariableTypes.tableInfo ...
            );

            if obj.isError
                createNewExpSheetInfo(obj);
                reset(obj);
                updateMsg(obj, "Failed to load info data from the Excel file. A new sheet has been created.", "Warning", obj.logLevel);
            end

            obj.tableSubstrate = importExcelFile( ...
                obj, ...
                obj.pathExp, ...
                "substrate", ...
                ReadRowNames = obj.tableReadRowName(2), ...
                refVariableNames = obj.tableVariableNames.tableSubstrate, ...
                refTypes = obj.tableVariableTypes.tableSubstrate ...
            );

            if obj.isError
                createNewExpSheetSubstrate(obj);
                reset(obj);
                updateMsg(obj, "Failed to load substrate data from the Excel file. A new sheet has been created.", "Warning", obj.logLevel);
            end

            obj.tableMS = importExcelFile( ...
                obj, ...
                obj.pathExp, ...
                "MS", ...
                ReadRowNames = obj.tableReadRowName(3), ...
                checkVariable = false ...
            );

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
                obj.tableMS = importExcelFile( ...
                    obj, ...
                    obj.pathExp, ...
                    sheetName, ...
                    ReadRowNames = obj.tableReadRowName(3), ...
                    checkVariable = false ...
                );
            catch
                obj.isError = true;
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
                        exportExcelFile( ...
                            obj, ...
                            obj.pathExp, ...
                            obj.(tableName), ...
                            sheetName, ...
                            WriteRowNames = obj.tableReadRowName(i) ...
                        );
                    case "csv"
                        % Unimplemented: CSV export
                        continue;
                end

            end % for i

        end % saveExcelData

    end % methods

    methods (Access = private)

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
