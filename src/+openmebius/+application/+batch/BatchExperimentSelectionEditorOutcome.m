classdef BatchExperimentSelectionEditorOutcome < openmebius.application.OperationOutcome
    % BATCHEXPERIMENTSELECTIONEDITOROUTCOME Child-editor preparation result.

    properties (SetAccess = private)
        Result
    end

    methods

        function obj = BatchExperimentSelectionEditorOutcome( ...
                succeeded, options)

            arguments
                succeeded (1, 1) logical
                options.Result = []
                options.ErrorMessage (1, 1) string = ""
                options.Exception = []
            end

            obj@openmebius.application.OperationOutcome( ...
                succeeded, ...
                ErrorMessage = options.ErrorMessage, ...
                Exception = options.Exception);
            obj.Result = options.Result;

        end % constructor

    end % methods

end % classdef
