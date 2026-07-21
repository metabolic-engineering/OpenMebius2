classdef UiLogSink < handle
    % UILOGSINK Delivers typed notifications to the in-app log renderer.

    properties (Constant)
        Name = "ui-log"
    end

    properties (Access = private)
        Renderer (1, 1) function_handle = @(~) []
    end

    methods

        function obj = UiLogSink(renderer)

            arguments
                renderer (1, 1) function_handle
            end

            obj.Renderer = renderer;

        end % constructor

        function write(obj, message)

            arguments
                obj
                message (1, 1) openmebius.core.notification.Message
            end

            obj.Renderer(message);

        end % write

    end % methods

end % classdef
