classdef BatchProgressEventData < event.EventData

    properties
        data
    end % properties

    methods

        function data = BatchProgressEventData(type, progress)

            arguments
                type (1, 1) string
                progress
            end

            switch type

                case "BatchIteration"

                    data.data = progress;

                case "GeneralMsg"

                    data.data = progress;

                case "FluxResult"

                    FVA_UB = progress.fluxVariability.fluxUB;
                    FVA_LB = progress.fluxVariability.fluxLB;

                    RSSIdx = progress.RSSIdx;
                    fieldName = "fluxResult" + sprintf("%04d", RSSIdx(1));
                    flux = progress.(fieldName).flux;
                    RSS = progress.(fieldName).RSS;
                    MDV = progress.(fieldName).MDV;
                    exitflag = progress.(fieldName).exitflag;

                    data.data.ID = progress.ID;
                    data.data.FVA_UB = FVA_UB;
                    data.data.FVA_LB = FVA_LB;
                    data.data.RSSIdx = RSSIdx;
                    data.data.flux = flux;
                    data.data.RSS = RSS;
                    data.data.MDV = MDV;
                    data.data.exitflag = exitflag;

                    unixtime = posixtime(datetime('now'));
                    data.data.time = unixtime;

                otherwise

                    error("Error: Unknown event type: %s", type);

            end % switch

        end % BatchProgressEventData

    end % methods

end % classdef
