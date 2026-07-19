classdef MFAAnalysisRunFactoryStub < handle

    properties
        Analysis
        CreateArguments cell = {}
    end

    methods

        function obj = MFAAnalysisRunFactoryStub(analysis)

            obj.Analysis = analysis;

        end

        function analysis = create(obj, varargin)

            obj.CreateArguments = varargin;
            analysis = obj.Analysis;
            analysis.configureReporters(varargin{:});

        end

    end

end
