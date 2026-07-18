classdef BatchConfigurationApplyRequest
    % BATCHCONFIGURATIONAPPLYREQUEST Validated RunConfig apply payload.

    properties (SetAccess = private)
        Config (1, 1) struct
        FragmentSelections (1, :) struct
        ApplySuggestion (1, 1) logical
        SuggestionTable table
    end

    methods

        function obj = BatchConfigurationApplyRequest( ...
                config, fragmentSelections, options)

            arguments
                config (1, 1) struct
                fragmentSelections (1, :) struct
                options.ApplySuggestion (1, 1) logical = false
                options.SuggestionTable table = table()
            end

            openmebius.domain.batch.BatchConfig.validate(config);

            if isempty(fragmentSelections)
                error( ...
                    "OpenMebius2:BatchConfigurationApplyRequest:" + ...
                    "MissingFragmentSelections", ...
                    "At least one MS fragment selection is required.");
            end

            obj.Config = config;
            obj.FragmentSelections = fragmentSelections;
            obj.ApplySuggestion = options.ApplySuggestion;
            obj.SuggestionTable = options.SuggestionTable;

        end % constructor

    end % methods

end % classdef
