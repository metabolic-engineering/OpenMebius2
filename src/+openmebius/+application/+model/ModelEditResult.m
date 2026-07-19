classdef ModelEditResult
    % MODELEDITRESULT Validation reports returned by model edit commands.

    properties (SetAccess = private)
        ModelReport = []
        MSReport = []
        AtomReport = []
    end

    methods

        function obj = ModelEditResult(options)

            arguments
                options.ModelReport = []
                options.MSReport = []
                options.AtomReport = []
            end

            obj.ModelReport = options.ModelReport;
            obj.MSReport = options.MSReport;
            obj.AtomReport = options.AtomReport;

        end % constructor

    end % methods

end % classdef
