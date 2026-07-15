classdef ExperimentMDVCalculationInput
    % EXPERIMENTMDVCALCULATIONINPUT Snapshot used to calculate one experiment.

    properties (SetAccess = private)
        ExperimentName (1, 1) string
        RawMS table
        ExperimentInfo table
        AtomTable table
        MSMetaboliteTable table
        ModelMSTable table
        TargetMetabolites (:, 1) string
    end

    methods

        function obj = ExperimentMDVCalculationInput(options)

            arguments
                options.ExperimentName (1, 1) string
                options.RawMS table
                options.ExperimentInfo table
                options.AtomTable table
                options.MSMetaboliteTable table
                options.ModelMSTable table
                options.TargetMetabolites string
            end

            if options.ExperimentName == ""
                error( ...
                    "OpenMebius2:ExperimentMDVCalculationInput:" + ...
                    "EmptyExperimentName", ...
                    "The experiment name must not be empty.");
            end

            if height(options.ExperimentInfo) ~= 1
                error( ...
                    "OpenMebius2:ExperimentMDVCalculationInput:" + ...
                    "InvalidExperimentInfo", ...
                    "Experiment information must contain exactly one row.");
            end

            obj.ExperimentName = options.ExperimentName;
            obj.RawMS = options.RawMS;
            obj.ExperimentInfo = options.ExperimentInfo;
            obj.AtomTable = options.AtomTable;
            obj.MSMetaboliteTable = options.MSMetaboliteTable;
            obj.ModelMSTable = options.ModelMSTable;
            obj.TargetMetabolites = options.TargetMetabolites(:);

        end % constructor

    end % methods

end % classdef
