classdef BatchTableSelectionMapperTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function mapsUniqueSelectedRowsInStableOrder(testCase)

            tableData = BatchTableSelectionMapperTest.batchTable();
            selection = [2, 1; 1, 2; 2, 3];

            batchIds = openmebius.presentation.batch ...
                .BatchTableSelectionMapper.selectedBatchIds( ...
                    tableData, selection);

            testCase.verifyEqual(batchIds, ["batch-b"; "batch-a"]);

        end

        function rejectsEmptySelection(testCase)

            testCase.verifyError( ...
                @() openmebius.presentation.batch ...
                    .BatchTableSelectionMapper.selectedBatchIds( ...
                        BatchTableSelectionMapperTest.batchTable(), ...
                        zeros(0, 2)), ...
                "OpenMebius2:BatchTableSelectionMapper:" + ...
                "EmptySelection");

        end

        function rejectsOutOfRangeSelection(testCase)

            testCase.verifyError( ...
                @() openmebius.presentation.batch ...
                    .BatchTableSelectionMapper.selectedBatchIds( ...
                        BatchTableSelectionMapperTest.batchTable(), ...
                        [3, 1]), ...
                "OpenMebius2:BatchTableSelectionMapper:" + ...
                "SelectionOutOfRange");

        end

        function rejectsTableWithoutId(testCase)

            tableData = table( ...
                ["A"; "B"], VariableNames = "Name");

            testCase.verifyError( ...
                @() openmebius.presentation.batch ...
                    .BatchTableSelectionMapper.selectedBatchIds( ...
                        tableData, [1, 1]), ...
                "OpenMebius2:BatchTableSelectionMapper:" + ...
                "MissingIdColumn");

        end

    end % methods (Test)

    methods (Static, Access = private)

        function value = batchTable()

            value = table( ...
                ["batch-a"; "batch-b"], ...
                ["A"; "B"], ...
                VariableNames = ["ID", "Name"]);

        end

    end % methods (Static, Access = private)

end % classdef
