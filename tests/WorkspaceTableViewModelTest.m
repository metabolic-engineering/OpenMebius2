classdef WorkspaceTableViewModelTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourcePath(~)

            root = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(root, "src"));

        end

    end

    methods (Test)

        function normalizesTableDisplayState(testCase)

            data = table( ...
                [1; 2], [3; 4], ...
                VariableNames = ["A", "B"], ...
                RowNames = ["first"; "second"]);

            viewModel = openmebius.presentation ...
                .WorkspaceTableViewModel( ...
                    Data = data, ...
                    ColumnEditable = true, ...
                    ErrorRows = [2; 1; 2]);

            testCase.verifyEqual(viewModel.Data, data);
            testCase.verifyEqual(viewModel.ColumnName, {'A', 'B'});
            testCase.verifyEqual( ...
                viewModel.RowName, {'first', 'second'});
            testCase.verifyEqual( ...
                viewModel.ColumnEditable, [true, true]);
            testCase.verifyEqual(viewModel.ErrorRows, [2; 1]);

        end

        function rejectsInvalidEditableColumns(testCase)

            data = array2table(ones(1, 2));

            testCase.verifyError( ...
                @() openmebius.presentation ...
                    .WorkspaceTableViewModel( ...
                        Data = data, ...
                        ColumnEditable = [true, false, true]), ...
                "OpenMebius2:WorkspaceTableViewModel:" + ...
                "InvalidEditableColumns");

        end

        function rejectsInvalidErrorRows(testCase)

            data = array2table(ones(2, 1));

            testCase.verifyError( ...
                @() openmebius.presentation ...
                    .WorkspaceTableViewModel( ...
                        Data = data, ErrorRows = 3), ...
                "OpenMebius2:WorkspaceTableViewModel:" + ...
                "InvalidErrorRows");

        end

    end % methods (Test)

end % classdef
