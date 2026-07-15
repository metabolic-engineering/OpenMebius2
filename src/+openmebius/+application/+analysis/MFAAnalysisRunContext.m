classdef MFAAnalysisRunContext < handle
    % MFAANALYSISRUNCONTEXT
    % Owns mutable values that exist only for one FluxAnalysis run.

    properties (SetAccess = private)
        Problem = []
        InstationaryInput = []
        ExperimentalData = []
        LowerBounds double = []
        UpperBounds double = []
        RightHandSide double = []
        SubstrateEMUs cell = {}
        OptimizationMDV double = []
        InitialFlux double = []
        InitialRightHandSides double = []
        InitialObjectiveValues double = []
        ObjectiveValues double = []
        Fluxes double = []
        MDVs double = []
    end

    methods

        function setExperimentalData(obj, data)

            obj.ExperimentalData = data;
            obj.OptimizationMDV = data.ExperimentalMDV;

        end

        function setBounds(obj, lowerBounds, upperBounds)

            obj.LowerBounds = lowerBounds;
            obj.UpperBounds = upperBounds;

        end

        function setRightHandSide(obj, rightHandSide)

            obj.RightHandSide = rightHandSide;

        end

        function setSubstrateEMUs(obj, substrateEMUs)

            obj.SubstrateEMUs = substrateEMUs;

        end

        function setInitialResult(obj, result)

            obj.Problem = result.Problem;
            obj.InitialFlux = result.Fluxes;
            obj.InitialRightHandSides = result.RightHandSides;
            obj.InitialObjectiveValues = result.ObjectiveValues;

        end

        function setWorkflowResult(obj, result)

            obj.ObjectiveValues = result.ObjectiveValues;
            obj.Fluxes = result.Fluxes;
            obj.MDVs = result.MDVs;

        end

        function setInstationaryInput(obj, input)

            obj.InstationaryInput = input;

        end

    end

end
