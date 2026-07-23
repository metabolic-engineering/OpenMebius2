classdef MFAExperimentalData
    % MFAEXPERIMENTALDATA
    % Immutable experimental MDV values and their fragment metadata.

    properties (SetAccess = private)
        ExperimentalMDV (:, :) double
        FragmentLabels (:, 1) string
        FragmentMask (:, 1) logical
        FragmentCount (1, 1) double
        ExperimentCount (1, 1) double
    end

    methods

        function obj = MFAExperimentalData(options)

            arguments
                options.ExperimentalMDV (:, :) double
                options.FragmentLabels
                options.FragmentMask
            end

            fragmentLabels = string(options.FragmentLabels(:));
            fragmentMask = logical(options.FragmentMask(:));
            fragmentCount = size(options.ExperimentalMDV, 1);

            if numel(fragmentLabels) ~= fragmentCount || ...
                    numel(fragmentMask) ~= fragmentCount
                error( ...
                    "OpenMebius2:MFAExperimentalData:" + ...
                    "FragmentDimensionMismatch", ...
                    "Fragment labels and mask must match the " + ...
                "experimental MDV row count.");
            end

            obj.ExperimentalMDV = options.ExperimentalMDV;
            obj.FragmentLabels = fragmentLabels;
            obj.FragmentMask = fragmentMask;
            obj.FragmentCount = fragmentCount;
            obj.ExperimentCount = size(options.ExperimentalMDV, 2);

        end % constructor

        function arrangedMDV = arrangeMDV(obj, linearizedMDV, options)

            arguments
                obj (1, 1) openmebius.mfa.MFAExperimentalData
                linearizedMDV (:, :) double
                options.ExperimentCount (1, 1) double = ...
                    obj.ExperimentCount
            end

            experimentCount = options.ExperimentCount;

            if ~isfinite(experimentCount) || ...
                    experimentCount < 0 || ...
                    fix(experimentCount) ~= experimentCount
                error( ...
                    "OpenMebius2:MFAExperimentalData:" + ...
                    "InvalidExperimentCount", ...
                    "The experiment count must be a nonnegative " + ...
                "integer.");
            end

            requiredValueCount = obj.FragmentCount * experimentCount;

            if numel(linearizedMDV) < requiredValueCount
                error( ...
                    "OpenMebius2:MFAExperimentalData:" + ...
                    "InsufficientMDVValues", ...
                    "The linearized MDV does not contain enough values " + ...
                "for the requested experiments.");
            end

            arrangedMDV = reshape( ...
                linearizedMDV(1:requiredValueCount), ...
                obj.FragmentCount, ...
                experimentCount);

        end % arrangeMDV

    end % methods

end % classdef
