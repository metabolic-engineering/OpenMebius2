classdef ResultInformation
    % RESULTINFORMATION Immutable information for one completed batch.

    properties (SetAccess = private)
        BatchID (1, 1) string
        BatchName (1, 1) string
        Description (1, 1) string
        ExperimentNames (:, 1) string
        StartedAtUtc (1, 1) string
        FinishedAtUtc (1, 1) string
        ElapsedSeconds (1, 1) double
        DifferentSettings (:, 1) string
        SettingsAvailable (1, 1) logical
        MDVDegreesOfFreedom (1, 1) double
        EffluxDegreesOfFreedom (1, 1) double
        ModelDegreesOfFreedom (1, 1) double
        HasEffluxContribution (1, 1) logical
        MDVRSSContribution (1, 1) double
        EffluxRSSContribution (1, 1) double
        ChiSquareThreshold (1, 1) double
    end

    methods

        function obj = ResultInformation(options)

            arguments
                options.BatchID (1, 1) string
                options.BatchName (1, 1) string = ""
                options.Description (1, 1) string = ""
                options.ExperimentNames (:, 1) string = strings(0, 1)
                options.StartedAtUtc (1, 1) string = ""
                options.FinishedAtUtc (1, 1) string = ""
                options.ElapsedSeconds (1, 1) double = NaN
                options.DifferentSettings (:, 1) string = strings(0, 1)
                options.SettingsAvailable (1, 1) logical = false
                options.MDVDegreesOfFreedom (1, 1) double = NaN
                options.EffluxDegreesOfFreedom (1, 1) double = NaN
                options.ModelDegreesOfFreedom (1, 1) double = NaN
                options.HasEffluxContribution (1, 1) logical = false
                options.MDVRSSContribution (1, 1) double = NaN
                options.EffluxRSSContribution (1, 1) double = NaN
                options.ChiSquareThreshold (1, 1) double = NaN
            end

            names = string(fieldnames(options));

            for nameIndex = 1:numel(names)
                name = names(nameIndex);
                obj.(name) = options.(name);
            end

        end % constructor

    end % methods

end % classdef
