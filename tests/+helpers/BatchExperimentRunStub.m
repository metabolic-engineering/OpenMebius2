classdef BatchExperimentRunStub < handle

    properties (SetAccess = private)
        Location
        fileExpList (1, :) string = "experiment-a.xlsx"
    end

    methods

        function obj = BatchExperimentRunStub(directory)

            obj.Location = openmebius.domain.experiment ...
                .ExperimentLocation.fromDirectory(string(directory));

        end

        function model = getModel(~)

            model = struct('pathModel', "model.xlsx");

        end

        function location = getExperimentLocation(obj)

            location = obj.Location;

        end

        function value = hasCalculatedMDV(~)

            value = true;

        end

    end

end
