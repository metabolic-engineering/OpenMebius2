classdef MassSpectrometryTemplateModelStub < handle

    properties
        TemplateData = [1, 2; 3, 4]
        Called (1, 1) logical = false
    end

    methods

        function data = getTemplateMSTable(obj)

            obj.Called = true;
            data = obj.TemplateData;

        end

    end

end
