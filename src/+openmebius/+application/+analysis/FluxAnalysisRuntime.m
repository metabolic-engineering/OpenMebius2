classdef FluxAnalysisRuntime
    % FLUXANALYSISRUNTIME
    % Immutable runtime objects and result location for one facade.

    properties (SetAccess = private)
        ResultLocation (1, 1) ...
            openmebius.domain.result.ResultLocation = ...
            openmebius.domain.result.ResultLocation.fromDirectory("")
        ResultID (1, 1) string
        ResultFilePath (1, 1) string
        IsExport (1, 1) logical
        IsError (1, 1) logical
        DirectoryMessage (1, 1) string
        DirectoryMessageLevel (1, 1) string
        Dependencies
        RunContext (1, 1) openmebius.application.analysis ...
            .MFAAnalysisRunContext
        ResultSession (1, 1) openmebius.application.analysis ...
            .MFAResultSession
    end

    methods

        function obj = FluxAnalysisRuntime(options)

            arguments
                options.ResultLocation (1, 1) ...
                    openmebius.domain.result.ResultLocation
                options.ResultID (1, 1) string
                options.ResultFilePath (1, 1) string
                options.IsExport (1, 1) logical
                options.IsError (1, 1) logical
                options.DirectoryMessage (1, 1) string
                options.DirectoryMessageLevel (1, 1) string ...
                    {mustBeMember(options.DirectoryMessageLevel, ...
                    ["Info", "Error"])}
                options.Dependencies
                options.RunContext (1, 1) ...
                    openmebius.application.analysis ...
                    .MFAAnalysisRunContext
                options.ResultSession (1, 1) ...
                    openmebius.application.analysis.MFAResultSession
            end

            if options.IsError && options.IsExport
                error( ...
                    "OpenMebius2:FluxAnalysisRuntime:" + ...
                    "InconsistentExportState", ...
                    "A failed runtime cannot export analysis results.");
            end

            obj.ResultLocation = options.ResultLocation;
            obj.ResultID = options.ResultID;
            obj.ResultFilePath = options.ResultFilePath;
            obj.IsExport = options.IsExport;
            obj.IsError = options.IsError;
            obj.DirectoryMessage = options.DirectoryMessage;
            obj.DirectoryMessageLevel = ...
                options.DirectoryMessageLevel;
            obj.Dependencies = options.Dependencies;
            obj.RunContext = options.RunContext;
            obj.ResultSession = options.ResultSession;

        end

    end

end
