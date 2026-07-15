classdef FluxResultEventData < event.EventData
    % FLUXRESULTEVENTDATA
    % Typed analysis result with a legacy data payload for existing views.

    properties (SetAccess = private)
        ID (1, 1) string = ""
        FVAUpperBounds double = []
        FVALowerBounds double = []
        RSSIndices double = []
        Flux double = []
        RSS double = []
        MDV double = []
        ExitFlag double = []
        Timestamp (1, 1) datetime = datetime("now")
        data (1, 1) struct = struct
    end

    methods

        function obj = FluxResultEventData(options)

            arguments
                options.ID (1, 1) string
                options.FVAUpperBounds double
                options.FVALowerBounds double
                options.RSSIndices double
                options.Flux double
                options.RSS double
                options.MDV double
                options.ExitFlag double
                options.Timestamp (1, 1) datetime = datetime( ...
                    "now", "TimeZone", "UTC")
            end

            obj.ID = options.ID;
            obj.FVAUpperBounds = options.FVAUpperBounds;
            obj.FVALowerBounds = options.FVALowerBounds;
            obj.RSSIndices = options.RSSIndices;
            obj.Flux = options.Flux;
            obj.RSS = options.RSS;
            obj.MDV = options.MDV;
            obj.ExitFlag = options.ExitFlag;
            obj.Timestamp = options.Timestamp;
            obj.data = struct( ...
                ID = obj.ID, ...
                FVA_UB = obj.FVAUpperBounds, ...
                FVA_LB = obj.FVALowerBounds, ...
                RSSIdx = obj.RSSIndices, ...
                flux = obj.Flux, ...
                RSS = obj.RSS, ...
                MDV = obj.MDV, ...
                exitflag = obj.ExitFlag, ...
                time = posixtime(obj.Timestamp));

        end

    end

end
