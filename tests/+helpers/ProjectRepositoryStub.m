classdef ProjectRepositoryStub < handle

    properties
        Exception = []
        SaveCalled (1, 1) logical = false
        SavedSession
    end

    methods

        function saveProject(obj, session)

            obj.SaveCalled = true;
            obj.SavedSession = session;

            if ~isempty(obj.Exception)
                throw(obj.Exception);
            end

        end

    end

end
