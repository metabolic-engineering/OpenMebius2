classdef CountingResultReader < openmebius.infrastructure.result.Hdf5ResultRepository
    properties
        SummaryReads = 0
        BestFitReads = 0
        CIReads = 0
        OptimizationReads = 0
    end
    methods
        function data = readResultSummary(obj, varargin)
            obj.SummaryReads = obj.SummaryReads + 1;
            data = readResultSummary@openmebius.infrastructure.result.Hdf5ResultRepository(obj, varargin{:});
        end
        function data = readBestFit(obj, varargin)
            obj.BestFitReads = obj.BestFitReads + 1;
            data = readBestFit@openmebius.infrastructure.result.Hdf5ResultRepository(obj, varargin{:});
        end
        function data = readConfidenceInterval(obj, varargin)
            obj.CIReads = obj.CIReads + 1;
            data = readConfidenceInterval@openmebius.infrastructure.result.Hdf5ResultRepository(obj, varargin{:});
        end
        function data = readOptimizationState(obj, varargin)
            obj.OptimizationReads = obj.OptimizationReads + 1;
            data = readOptimizationState@openmebius.infrastructure.result.Hdf5ResultRepository(obj, varargin{:});
        end
    end
end
