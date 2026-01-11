classdef CustomProgressBar < handle

    properties
        Parent
        ProgressAxes
        BarPatch
        ProgressText
        Progress (1, 1) double = 0
    end

    methods

        function app = CustomProgressBar(parent, row, col)

            if nargin < 3
                col = 1;
            end

            if nargin < 2
                row = 1;
            end

            app.Parent = parent;

            ax = uiaxes(parent);
            ax.Layout.Row = row;
            ax.Layout.Column = col;
            ax.XLim = [0 1];
            ax.YLim = [0 1];
            ax.XTick = [];
            ax.YTick = [];
            ax.Box = 'on';
            ax.Title.String = '0%';
            app.ProgressAxes = ax;

            app.BarPatch = patch(ax, [0 0 0 0], [0 0 1 1], 'b');

        end % constructor

        function update(app, progress)
            progress = max(0, min(1, progress));
            app.Progress = progress;

            x = [0, progress, progress, 0];
            set(app.BarPatch, 'XData', x);

            app.ProgressAxes.Title.String = sprintf('%.0f%%', progress * 100);
        end % method update

        function setProgress(app, progress, msg)

            if nargin < 3
                msg = "";
            end

            app.update(progress);

            if strlength(msg) > 0
                app.ProgressAxes.Title.String = sprintf('%.0f%% - %s', progress * 100, msg);
            end

            drawnow limitrate;
        end % method setProgress

        function close(app)

            if ~isempty(app.ProgressAxes) && isvalid(app.ProgressAxes)
                delete(app.ProgressAxes);
            end

        end % method close

    end % methods

end % classdef CustomProgressBar
