classdef BatchExperimentSelectionEventData < event.EventData
    % BATCHEXPERIMENTSELECTIONEVENTDATA Carries a typed batch selection.

    properties (SetAccess = private)
        Selection
    end

    methods

        function obj = BatchExperimentSelectionEventData(selection)

            arguments
                selection (1, 1) openmebius.domain.batch ...
                    .BatchExperimentSelection
            end

            obj.Selection = selection;

        end % constructor

    end % methods

end % classdef
