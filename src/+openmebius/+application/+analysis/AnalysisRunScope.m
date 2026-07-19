classdef AnalysisRunScope < handle
    % ANALYSISRUNSCOPE
    % Owns reproducibility metadata for one MFA analysis run.

    properties (SetAccess = private)
        Metadata (1, 1) struct = struct
        IsEnabled (1, 1) logical = false
        IsStarted (1, 1) logical = false
        StartSucceeded (1, 1) logical = true
        StartedAtUtc (1, 1) string = ""
        RandomState (1, 1) struct = struct
        FinishCount (1, 1) double = 0
    end

    properties (Access = private)
        Lifecycle
        ResultLocation
        ResultFilePath (1, 1) string = ""
        FailureReporter (1, 1) function_handle = @(~) []
    end

    methods

        function obj = AnalysisRunScope( ...
                lifecycle, config, batchID, model, experimentNames, ...
                provenance, resultLocation, resultFilePath, options)

            arguments
                lifecycle
                config
                batchID
                model
                experimentNames
                provenance (1, 1) struct
                resultLocation
                resultFilePath (1, 1) string
                options.IsExport (1, 1) logical = true
                options.FailureReporter (1, 1) function_handle = ...
                    @(~) []
                options.StartedAtUtc (1, 1) string = string(datetime( ...
                    "now", ...
                    "TimeZone", "UTC", ...
                    "Format", "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"))
                options.RandomState (1, 1) struct = rng
            end

            obj.Lifecycle = lifecycle;
            obj.ResultLocation = resultLocation;
            obj.ResultFilePath = resultFilePath;
            obj.FailureReporter = options.FailureReporter;
            obj.StartedAtUtc = options.StartedAtUtc;
            obj.RandomState = options.RandomState;
            obj.IsEnabled = options.IsExport;

            if ~obj.IsEnabled
                return
            end

            [obj.Metadata, obj.StartSucceeded, message] = ...
                obj.Lifecycle.start( ...
                config, ...
                batchID, ...
                model, ...
                experimentNames, ...
                provenance, ...
                obj.StartedAtUtc, ...
                obj.RandomState, ...
                resultLocation, ...
                resultFilePath);
            obj.IsStarted = obj.StartSucceeded;

            if ~obj.StartSucceeded
                obj.FailureReporter(string(message));
            end

        end

        function finish(obj, isError, isCanceled)

            arguments
                obj (1, 1) openmebius.application.analysis ...
                    .AnalysisRunScope
                isError (1, 1) logical
                isCanceled (1, 1) logical
            end

            if ~obj.IsEnabled || ~obj.IsStarted
                return
            end

            errors = obj.Lifecycle.finish( ...
                obj.ResultLocation, ...
                obj.ResultFilePath, ...
                obj.Metadata, ...
                isError, ...
                isCanceled);
            obj.FinishCount = obj.FinishCount + 1;

            for iError = 1:numel(errors)
                obj.FailureReporter(string(errors(iError)));
            end

        end

    end

end
