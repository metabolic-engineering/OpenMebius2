classdef ProgressBarFactory
    % PROGRESSBARFACTORY Creates progress UI after its parent is available.

    methods

        function progressBar = create(~, parent, row, column)

            progressBar = CustomProgressBar(parent, row, column);

        end % create

    end % methods

end % classdef
