classdef ResultPlotViewModel

    properties (SetAccess = private)
        Kind openmebius.presentation.result.ResultPlotKind

        MainPlot struct
        SubPlot struct

        Notification = []
    end

    methods

        function obj = ResultPlotViewModel(options)

            arguments
                options.Kind openmebius.presentation.result.ResultPlotKind = ...
                    openmebius.presentation.result.ResultPlotKind.None
                options.MainPlot struct = struct()
                options.SubPlot struct = struct()
                options.Notification = []
            end

            obj.Kind = options.Kind;
            obj.MainPlot = options.MainPlot;
            obj.SubPlot = options.SubPlot;
            obj.Notification = options.Notification;

        end

    end

    methods (Static)

        function obj = none(options)

            arguments
                options.Notification = []
            end

            obj = openmebius.presentation.result.ResultPlotViewModel( ...
                Kind = openmebius.presentation.result.ResultPlotKind.None, ...
                MainPlot = struct(), ...
                SubPlot = struct(), ...
                Notification = options.Notification);

        end

    end

end
