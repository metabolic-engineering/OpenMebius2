classdef MFAResultCoordinatorFailureStub

    methods

        function [result, status, isSuccess, message] = ...
                writeGeneral(~, ~, status, ~, ~, ~, ~)

            result = struct(Value = 1);
            isSuccess = false;
            message = "checkpoint failed";

        end

    end

end
