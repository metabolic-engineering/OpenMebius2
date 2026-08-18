classdef FailingResultTableBuilderStub

    methods

        function [value, message] = fluxComparison(~, varargin)

            value = table(); %#ok<NASGU>
            message = ""; %#ok<NASGU>
            error( ...
                "OpenMebius2:Test:SyntheticComparisonFailure", ...
                "synthetic comparison failure");

        end

    end

end
