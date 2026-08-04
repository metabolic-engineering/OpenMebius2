classdef MFAAnalysisRunContext < handle
    % MFAANALYSISRUNCONTEXT
    % Owns mutable values that exist only for one MFA analysis run.

    properties (SetAccess = private)
        InstationaryInput = []
        ExperimentalData = []
        InitialResult = []
        WorkflowResult = []
        LowerBounds double = []
        UpperBounds double = []
        RightHandSide double = []
        SubstrateEMUs cell = {}
    end

    methods

        function setExperimentalData(obj, data)

            obj.ExperimentalData = data;

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

            arguments
                obj (1, 1) openmebius.application.analysis ...
                    .MFAAnalysisRunContext
                result (1, 1) openmebius.mfa ...
                    .InitialFluxWorkflowResult
            end

            if result.IsError || result.IsCanceled
                error( ...
                    "OpenMebius2:MFAAnalysisRunContext:" + ...
                    "UnsuccessfulInitialResult", ...
                    "Only a successful initial-flux result can be " + ...
                "stored in the analysis context.");
            end

            obj.InitialResult = result;

        end

        function values = experimentalMDV(obj)

            if isempty(obj.ExperimentalData)
                values = [];
            else
                values = obj.ExperimentalData.ExperimentalMDV;
            end

        end % experimentalMDV

        function result = requireInitialResult(obj)

            if isempty(obj.InitialResult)
                error( ...
                    "OpenMebius2:MFAAnalysisRunContext:" + ...
                    "MissingInitialResult", ...
                    "The analysis context does not contain a " + ...
                "successful initial-flux result.");
            end

            result = obj.InitialResult;

        end % requireInitialResult

        function setWorkflowResult(obj, result)

            arguments
                obj (1, 1) openmebius.application.analysis ...
                    .MFAAnalysisRunContext
                result (1, 1) openmebius.mfa.MFAWorkflowResult
            end

            obj.WorkflowResult = result;

        end

        function fluxes = workflowFluxes(obj)

            if isempty(obj.WorkflowResult)
                fluxes = [];
            else
                fluxes = obj.WorkflowResult.Fluxes;
            end

        end % workflowFluxes

        function result = requireWorkflowResult(obj)

            if isempty(obj.WorkflowResult)
                error( ...
                    "OpenMebius2:MFAAnalysisRunContext:" + ...
                    "MissingWorkflowResult", ...
                    "The analysis context does not contain an MFA " + ...
                "workflow result.");
            end

            result = obj.WorkflowResult;

        end % requireWorkflowResult

        function setInstationaryInput(obj, input)

            obj.InstationaryInput = input;

        end

    end

end
