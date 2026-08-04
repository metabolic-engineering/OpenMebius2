classdef InitialFluxWorkflowSpy < handle

    properties (SetAccess = private)
        Result
        LastInput = []
        MessageReporter (1, 1) function_handle = @(~, ~) []
        CancellationRequested (1, 1) function_handle = @() false
        CallCount (1, 1) double = 0
    end

    methods

        function obj = InitialFluxWorkflowSpy(result)

            obj.Result = result;

        end

        function result = run(obj, input, options)

            arguments
                obj (1, 1) helpers.InitialFluxWorkflowSpy
                input (1, 1) openmebius.mfa.InitialFluxWorkflowInput
                options.MessageReporter (1, 1) function_handle = ...
                    @(~, ~) []
                options.CancellationRequested (1, 1) ...
                    function_handle = @() false
            end

            obj.LastInput = input;
            obj.MessageReporter = options.MessageReporter;
            obj.CancellationRequested = ...
                options.CancellationRequested;
            obj.CallCount = obj.CallCount + 1;
            result = obj.Result;

        end

    end

end
