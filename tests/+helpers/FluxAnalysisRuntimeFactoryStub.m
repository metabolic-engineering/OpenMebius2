classdef FluxAnalysisRuntimeFactoryStub < handle

    properties (SetAccess = private)
        Runtime
        CallCount (1, 1) double = 0
        LastConfiguration = []
    end

    methods

        function obj = FluxAnalysisRuntimeFactoryStub(runtime)

            obj.Runtime = runtime;

        end

        function runtime = create( ...
                obj, ~, ~, configuration, varargin)

            obj.CallCount = obj.CallCount + 1;
            obj.LastConfiguration = configuration;
            runtime = obj.Runtime;

        end

    end

end
