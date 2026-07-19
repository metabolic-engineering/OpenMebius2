classdef SectionStatusState < handle
    % SECTIONSTATUSSTATE Owns the four status values rendered by the main app.

    properties (Access = private)
        Values (4, 1) string
    end

    methods

        function obj = SectionStatusState()
            obj.reset();
        end

        function rows = update(obj, section, status)
            [obj.Values, rows] = ...
                openmebius.presentation.status.StatusPresenter.update( ...
                    obj.Values, section, status);
        end

        function rows = reset(obj)
            obj.Values = ...
                openmebius.presentation.status.StatusPresenter.initial();
            rows = openmebius.presentation.status.StatusPresenter.rows( ...
                obj.Values);
        end

    end

end
