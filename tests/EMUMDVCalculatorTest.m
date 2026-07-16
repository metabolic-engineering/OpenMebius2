classdef EMUMDVCalculatorTest < matlab.unittest.TestCase

    methods (Test)

        function calculateEvaluatesSteadyStateNetwork(testCase)

            calculator = openmebius.mfa.EMUMDVCalculator();
            snapshot = EMUMDVCalculatorTest.createSnapshot();
            substrateEMU = [0.25, 0.75];

            actual = calculator.calculate(snapshot, 1, substrateEMU);
            expected = substrateEMU' / (2 + 1e-8);

            testCase.verifyEqual(actual, expected, AbsTol = 1e-12);

        end

        function substituteAnBnAppliesFluxEntries(testCase)

            payload = EMUMDVCalculatorTest.createPayload();
            payload.globalAnList = [1, 1, 1, 1, 0.5];
            payload.globalBnList = [1, 1, 1, 1, -0.25];
            snapshot = openmebius.domain.model ...
                .EMUNetworkSnapshot(payload);
            calculator = openmebius.mfa.EMUMDVCalculator();

            [an, bn] = calculator.substituteAnBn(snapshot, 4);

            testCase.verifyEqual(an, 4);
            testCase.verifyEqual(bn, 0);

        end

        function substituteCnAppliesPoolSizes(testCase)

            payload = EMUMDVCalculatorTest.createPayload();
            payload.globalCn = false(2, 2, 1);
            payload.globalCn(1, 1, 1) = true;
            payload.globalCn(2, 2, 1) = true;
            payload.globalCnDiag = zeros(2, 1);
            snapshot = openmebius.domain.model ...
                .EMUNetworkSnapshot(payload);
            calculator = openmebius.mfa.EMUMDVCalculator();

            actual = calculator.substituteCn(snapshot, [2; 4]);

            testCase.verifyEqual(actual, [0.5; 0.25]);

        end

        function substituteCnPreservesValidationIdentifiers(testCase)

            payload = EMUMDVCalculatorTest.createPayload();
            payload.globalCn = false(1, 2, 1);
            payload.globalCnDiag = zeros(1, 1);
            snapshot = openmebius.domain.model ...
                .EMUNetworkSnapshot(payload);
            calculator = openmebius.mfa.EMUMDVCalculator();

            testCase.verifyError( ...
                @() calculator.substituteCn(snapshot, 1), ...
                "EMUModel:PoolSizeDimensionMismatch");
            testCase.verifyError( ...
                @() calculator.substituteCn(snapshot, [1; 0]), ...
                "EMUModel:InvalidPoolSize");

        end

    end % methods (Test)

    methods (Static, Access = private)

        function snapshot = createSnapshot()

            snapshot = openmebius.domain.model.EMUNetworkSnapshot( ...
                EMUMDVCalculatorTest.createPayload());

        end

        function payload = createPayload()

            sizeInfo = table( ...
                1, 1, 1, ...
                VariableNames = ["EMUSize", "An", "Bn"]);
            payload = struct( ...
                "tableEMU", table(), ...
                "tableEMUReaction", table(), ...
                "tableEMUSizeInfo", sizeInfo, ...
                "globalAn", 2, ...
                "globalAnList", zeros(0, 5), ...
                "globalBn", 1, ...
                "globalBnList", zeros(0, 5), ...
                "globalCn", false(1, 1, 1), ...
                "globalCnDiag", 0, ...
                "globalXn", zeros(1, 2, 1), ...
                "globalYn", zeros(1, 2, 1), ...
                "globalYnList", [1, 1, 0, 1, 1, 0], ...
                "globalMDVList", [1, 0, 1, 1, 1], ...
                "globalMDVSize", 2);

        end

    end % methods (Static, Access = private)

end % classdef
