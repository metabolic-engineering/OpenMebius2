classdef ResultComparisonQueryServiceStub

    methods

        function [data, mask] = readMany(~, ids, varargin)

            data = repmat({struct("status", true(1, 4))}, ...
                1, numel(ids));
            mask = true(1, numel(ids));

        end

    end

end
