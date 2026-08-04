classdef PathwayModelStub < handle

    properties
        PathwayData openmebius.application.model.ModelPathwayData = ...
            openmebius.application.model.ModelPathwayData()
        Exception = []
    end

    methods

        function value = getPathwayData(obj)

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

            value = obj.PathwayData;

        end

    end

end
