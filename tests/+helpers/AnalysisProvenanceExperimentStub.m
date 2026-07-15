classdef AnalysisProvenanceExperimentStub < handle

    properties (SetAccess = private)
        fileExpList (1, :) string
        Location
    end

    methods

        function obj = AnalysisProvenanceExperimentStub(directory, files)

            obj.fileExpList = string(files(:))';
            obj.Location = openmebius.domain.experiment ...
                .ExperimentLocation.fromDirectory(string(directory));

        end

        function location = getExperimentLocation(obj)

            location = obj.Location;

        end

    end

end
