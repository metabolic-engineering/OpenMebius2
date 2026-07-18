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

        function result = load(obj, session)

            obj.LoadCalled = true;
            obj.Session = session;
            obj.throwIfNeeded();
            result = obj.LoadResult;

        end

        function result = initialize(obj, session)

            obj.InitializeCalled = true;
            obj.Session = session;
            obj.throwIfNeeded();
            result = obj.InitializeResult;

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
