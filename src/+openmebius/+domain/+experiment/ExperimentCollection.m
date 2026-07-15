classdef ExperimentCollection < handle
    % EXPERIMENTCOLLECTION Owns the mutable state of loaded experiments.

    properties (SetAccess = private)
        Location openmebius.domain.experiment.ExperimentLocation
        FileNames (1, :) string = strings(1, 0)
        FieldNames (1, :) string = strings(1, 0)
        Data (1, :) = struct
        ModelPath (1, 1) string = ""
        Model = []
        AtomTable table = table()
        InfoTable table = table()
        TracerTableFull table = table()
        TracerTable table = table()
        UptakeTableFull table = table()
        UptakeTable table = table()
        DefaultSubstrateVariableNames (1, :) string = strings(1, 0)
        DefaultSubstrateVariableTypes (1, :) string = strings(1, 0)
    end

    properties (Dependent)
        Count (1, 1) double
        FileBaseNames (1, :) string
    end

    methods

        function obj = ExperimentCollection(location)

            arguments
                location openmebius.domain.experiment.ExperimentLocation
            end

            obj.Location = location;

        end % constructor

        function count = get.Count(obj)

            count = numel(obj.FileNames);

        end % get.Count

        function names = get.FileBaseNames(obj)

            names = erase(obj.FileNames, ".xlsx");

        end % get.FileBaseNames

        function replaceFiles(obj, fileNames)

            fileNames = string(fileNames);
            obj.FileNames = reshape(fileNames, 1, []);
            obj.FieldNames = matlab.lang.makeValidName(obj.FileNames);

        end % replaceFiles

        function replaceData(obj, data)

            arguments
                obj
                data (1, :)
            end

            obj.Data = data;

        end % replaceData

        function replaceModel(obj, model, modelPath)

            if nargin < 3
                modelPath = obj.ModelPath;
            end

            obj.Model = model;
            obj.ModelPath = string(modelPath);
            obj.AtomTable = model.tableAtom;

        end % replaceModel

        function replaceInfoTable(obj, data)

            arguments
                obj
                data table
            end

            obj.InfoTable = data;

        end % replaceInfoTable

        function replaceTracerTables(obj, data, fullData)

            arguments
                obj
                data table
                fullData table = obj.TracerTableFull
            end

            obj.TracerTable = data;
            obj.TracerTableFull = fullData;

        end % replaceTracerTables

        function replaceUptakeTables(obj, data, fullData)

            arguments
                obj
                data table
                fullData table = obj.UptakeTableFull
            end

            obj.UptakeTable = data;
            obj.UptakeTableFull = fullData;

        end % replaceUptakeTables

        function replaceDefaultSubstrateMetadata( ...
                obj, variableNames, variableTypes)

            arguments
                obj
                variableNames (1, :) string
                variableTypes (1, :) string
            end

            if numel(variableNames) ~= numel(variableTypes)
                error( ...
                    "OpenMebius2:ExperimentCollection:" + ...
                    "DefaultVariableCountMismatch", ...
                    "Default substrate names and types must have " + ...
                    "the same length.");
            end

            obj.DefaultSubstrateVariableNames = variableNames;
            obj.DefaultSubstrateVariableTypes = variableTypes;

        end % replaceDefaultSubstrateMetadata

    end % methods

end % classdef
