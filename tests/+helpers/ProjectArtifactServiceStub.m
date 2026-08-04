classdef ProjectArtifactServiceStub < handle

    properties
        LoadResult
        InitializeResult
        Exception = []
        LoadCalled (1, 1) logical = false
        InitializeCalled (1, 1) logical = false
        Session
    end

    methods

        function result = load(obj, session, options)

            arguments
                obj
                session
                options.AllowEmptyExperiments (1, 1) logical = false
            end

            obj.Session = session;
            obj.throwIfNeeded();
            if options.AllowEmptyExperiments
                obj.InitializeCalled = true;
                result = obj.InitializeResult;
            else
                obj.LoadCalled = true;
                result = obj.LoadResult;
            end

        end

    end

    methods (Access = private)

        function throwIfNeeded(obj)

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

        end

    end

end
