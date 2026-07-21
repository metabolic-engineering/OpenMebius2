classdef ResultIndexStub < handle

    methods

        function [data, mask] = loadResultFiles(~, batchIds)

            data = repmat({struct()}, size(batchIds));
            mask = true(size(batchIds));

        end

        function values = getRSS(~, data)

            values = ones(size(data));

        end

        function values = getIsPassedChi2Test(~, data)

            values = true(size(data));

        end

    end

end
