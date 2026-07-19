classdef RawMSImportServiceStub < handle

    properties
        Result
        Exception = []
        Called (1, 1) logical = false
        Inputs cell = cell(0, 1)
    end

    methods

        function result = importShimadzuASCII(obj, varargin)

            obj.Called = true;
            obj.Inputs = varargin;

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

            result = obj.Result;

        end

    end

end
