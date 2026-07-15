classdef MFAResultSessionStub < handle

    properties
        Result = struct
        Status (1, :) double = zeros(1, 4)
        Calls (:, 1) string = strings(0, 1)
        SummaryObjectiveValues double = []
        SummaryOrder double = []
        SummaryThreshold (1, 1) double = NaN
    end

    methods

        function writeGeneral(obj, varargin)

            obj.record("general");

        end

        function writeModel(obj, varargin)

            obj.record("model");

        end

        function writeFluxVariability(obj, varargin)

            obj.record("fva");

        end

        function writeInitialFlux(obj, varargin)

            obj.record("initial");

        end

        function writeIteration(obj, varargin)

            obj.record("iteration");

        end

        function writeSummary( ...
                obj, objectiveValues, order, threshold)

            obj.record("summary");
            obj.SummaryObjectiveValues = objectiveValues;
            obj.SummaryOrder = order;
            obj.SummaryThreshold = threshold;

        end

    end

    methods (Access = private)

        function record(obj, call)

            obj.Calls(end + 1, 1) = call;

        end

    end

end
