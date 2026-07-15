classdef BatchExperimentNotificationStub < handle

    properties (SetAccess = private)
        Location
    end

    methods

        function obj = BatchExperimentNotificationStub(directory)

            obj.Location = openmebius.domain.experiment ...
                .ExperimentLocation.fromDirectory(directory);

        end

        function model = getModel(~)

            model = struct;

        end

        function location = getExperimentLocation(obj)

            location = obj.Location;

        end

        function value = hasCalculatedMDV(~)

            value = false;

        end

    end

end
