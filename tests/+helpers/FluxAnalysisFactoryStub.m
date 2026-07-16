classdef FluxAnalysisFactoryStub < handle

    properties
        Analysis
        CreateArguments cell = {}
    end

    methods

        function obj = FluxAnalysisFactoryStub(analysis)

            obj.Analysis = analysis;

        end

        function analysis = create(obj, varargin)

            obj.CreateArguments = varargin;
            analysis = obj.Analysis;

        end

    end

end
