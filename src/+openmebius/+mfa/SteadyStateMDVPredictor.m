classdef SteadyStateMDVPredictor
    % STEADYSTATEMDVPREDICTOR
    % Calculates and aligns steady-state MDVs across labeling experiments.

    methods

        function predictedMDV = predictByExperiment( ...
                ~, model, flux, substrateEMUs)

            arguments
                ~
                model
                flux (:, 1) double
                substrateEMUs cell
            end

            experimentCount = numel(substrateEMUs);

            if experimentCount == 0
                predictedMDV = zeros(0, 0);
                return;
            end

            firstPrediction = calculateMDV( ...
                model, flux, substrateEMUs{1});
            firstPrediction = ...
                openmebius.mfa.SteadyStateMDVPredictor ...
                .normalizePrediction(firstPrediction);
            fragmentCount = numel(firstPrediction);
            predictedMDV = nan(fragmentCount, experimentCount);
            predictedMDV(:, 1) = firstPrediction;

            for experimentIndex = 2:experimentCount
                prediction = calculateMDV( ...
                    model, flux, substrateEMUs{experimentIndex});
                prediction = ...
                    openmebius.mfa.SteadyStateMDVPredictor ...
                    .normalizePrediction(prediction);

                if numel(prediction) ~= fragmentCount
                    error( ...
                        "OpenMebius2:SteadyStateMDVPredictor:" + ...
                        "FragmentCountMismatch", ...
                        "Predicted MDV fragment counts must match across " + ...
                    "labeling experiments.");
                end

                predictedMDV(:, experimentIndex) = prediction;
            end

        end % predictByExperiment

        function linearizedMDV = predictLinearized( ...
                obj, model, flux, substrateEMUs)

            arguments
                obj (1, 1) openmebius.mfa.SteadyStateMDVPredictor
                model
                flux (:, 1) double
                substrateEMUs cell
            end

            predictedMDV = obj.predictByExperiment( ...
                model, flux, substrateEMUs);
            linearizedMDV = predictedMDV(:);

        end % predictLinearized

    end % methods

    methods (Static, Access = private)

        function prediction = normalizePrediction(prediction)

            if ~isnumeric(prediction) || ~isvector(prediction) || ...
                    isempty(prediction)
                error( ...
                    "OpenMebius2:SteadyStateMDVPredictor:" + ...
                    "InvalidPrediction", ...
                    "Each predicted MDV must be a nonempty numeric " + ...
                "vector.");
            end

            prediction = double(prediction(:));

        end % normalizePrediction

    end % methods (Static, Access = private)

end % classdef
