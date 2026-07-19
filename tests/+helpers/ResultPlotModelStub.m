classdef ResultPlotModelStub < handle

    properties
        PathwayData openmebius.application.model.ModelPathwayData = ...
            openmebius.application.model.ModelPathwayData()
    end

    methods

        function value = getPathwayData(obj)

            value = obj.PathwayData;

        end

    end

end
