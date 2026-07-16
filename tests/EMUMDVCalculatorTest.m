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

        function calculateDerivativeEvaluatesInstationaryNetwork(testCase)

            payload = EMUMDVCalculatorTest.createPayload();
            payload.globalCn = true(1, 1, 1);
            snapshot = openmebius.domain.model ...
                .EMUNetworkSnapshot(payload);
            calculator = openmebius.mfa.EMUMDVCalculator();

            actual = calculator.calculateDerivative( ...
                snapshot, [0.1; 0.2], 1, [0.25, 0.75], 2);

            testCase.verifyEqual( ...
                actual, [-0.025; -0.175], AbsTol = 1e-12);

        end

        function calculateTimeCourseIntegratesFirstOrderNetwork(testCase)

            payload = EMUMDVCalculatorTest.createPayload();
            payload.globalAn = -1;
            payload.globalBn = -1;
            payload.globalCn = true(1, 1, 1);
            snapshot = openmebius.domain.model ...
                .EMUNetworkSnapshot(payload);
            calculator = openmebius.mfa.EMUMDVCalculator();
            substrateEMU = [0.25, 0.75];
            timePoints = [0; 0.5; 1];

            actual = calculator.calculateTimeCourse( ...
                snapshot, 1, substrateEMU, 1, timePoints);
            expected = substrateEMU' * (1 - exp(-timePoints'));

            testCase.verifyEqual(actual, expected, AbsTol = 1e-3);

        end

        function assembleTimeCourseConvolvesEachTimePoint(testCase)

            snapshot = EMUMDVCalculatorTest.createConvolutionSnapshot();
            first = zeros(2, 3, 2);
            first(1, 1:2, 1) = [0.2, 0.8];
            first(2, 1:2, 1) = [0.5, 0.5];
            second = zeros(2, 3, 2);
            second(1, 1:2, 1) = [0.6, 0.4];
            second(2, 1:2, 1) = [0.25, 0.75];
            xnTimeCourse = [first(:)'; second(:)'];
            calculator = openmebius.mfa.EMUMDVCalculator();

            actual = calculator.assembleTimeCourse( ...
                snapshot, xnTimeCourse);

            testCase.verifyEqual( ...
                actual, ...
                [0.1, 0.15; 0.5, 0.55; 0.4, 0.3], ...
                AbsTol = 1e-12);

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

        function snapshot = createConvolutionSnapshot()

            sizeInfo = table( ...
                [1; 2], [2; 0], [0; 0], ...
                VariableNames = ["EMUSize", "An", "Bn"]);
            payload = struct( ...
                "tableEMU", table(), ...
                "tableEMUReaction", table(), ...
                "tableEMUSizeInfo", sizeInfo, ...
                "globalXn", zeros(2, 3, 2), ...
                "globalMDVList", ...
                    [1, 0, 1, 1, 1; 1, 1, 2, 1, 2], ...
                "globalMDVSize", 3);
            snapshot = openmebius.domain.model ...
                .EMUNetworkSnapshot(payload);

        end

    end % methods (Static, Access = private)

end % classdef
