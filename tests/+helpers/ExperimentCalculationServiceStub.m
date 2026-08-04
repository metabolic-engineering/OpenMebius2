classdef ExperimentCalculationServiceStub < handle

    properties
        Result
        Exception = []
        Called (1, 1) logical = false
        Inputs (1, 6) cell = cell(1, 6)
    end

    methods

        function result = calculateMDV(obj, varargin)

            obj.Called = true;
            obj.Inputs = varargin;

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

            result = obj.Result;

        end

    end

end
