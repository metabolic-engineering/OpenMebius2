classdef EffluxFreeSessionFactoryStub < handle

    properties (SetAccess = private)
        Session
        Model
        Substrates (:, 1) string = strings(0, 1)
        Reporter (1, 1) function_handle = @(~, ~) []
        CallCount (1, 1) double = 0
    end

    methods

        function obj = EffluxFreeSessionFactoryStub(session)

            obj.Session = session;

        end

        function session = create(obj, model, substrates, reporter)

            obj.Model = model;
            obj.Substrates = string(substrates(:));
            obj.Reporter = reporter;
            obj.CallCount = obj.CallCount + 1;
            session = obj.Session;

        end

    end

end
