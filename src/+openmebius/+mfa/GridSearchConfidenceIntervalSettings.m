classdef GridSearchConfidenceIntervalSettings
    % GRIDSEARCHCONFIDENCEINTERVALSETTINGS Validated grid-search settings.

    properties (SetAccess = private)
        Delta (1, 1) double
        Threshold (1, 1) string
        PointCount (1, 1) double
        IterationCount (1, 1) double
        Alpha (1, 1) double
        UseParallel (1, 1) logical
    end

    methods

        function obj = GridSearchConfidenceIntervalSettings(options)

            arguments
                options.Delta (1, 1) double = 1
                options.Threshold (1, 1) string = "chi-sq"
                options.PointCount (1, 1) double = 10
                options.IterationCount (1, 1) double = 30
                options.Alpha (1, 1) double = 0.05
                options.UseParallel (1, 1) logical = true
            end

            if ~isfinite(options.Delta) || options.Delta <= 0
                error( ...
                    "OpenMebius2:GridSearchConfidenceIntervalSettings:" + ...
                    "InvalidDelta", ...
                    "Delta must be a finite, positive number.");
            end

            if ~ismember(options.Threshold, ...
                    ["chi-sq", "f-distribution"])
                error( ...
                    "OpenMebius2:GridSearchConfidenceIntervalSettings:" + ...
                    "InvalidThreshold", ...
                    "The grid-search threshold is unsupported.");
            end

            obj.validatePositiveInteger(options.PointCount, "PointCount");
            obj.validatePositiveInteger( ...
                options.IterationCount, "IterationCount");

            if ~isfinite(options.Alpha) || ...
                    options.Alpha < 0 || options.Alpha > 1
                error( ...
                    "OpenMebius2:GridSearchConfidenceIntervalSettings:" + ...
                    "InvalidAlpha", ...
                    "Alpha must be between zero and one.");
            end

            obj.Delta = options.Delta;
            obj.Threshold = options.Threshold;
            obj.PointCount = options.PointCount;
            obj.IterationCount = options.IterationCount;
            obj.Alpha = options.Alpha;
            obj.UseParallel = options.UseParallel;

        end

    end

    methods (Static, Access = private)

        function validatePositiveInteger(value, name)

            if ~isfinite(value) || value < 1 || fix(value) ~= value
                error( ...
                    "OpenMebius2:GridSearchConfidenceIntervalSettings:" + ...
                    "InvalidPositiveInteger", ...
                    "%s must be a positive integer.", name);
            end

        end

    end

end
