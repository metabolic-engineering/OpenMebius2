classdef EMUNetworkEnumeratorTest < matlab.unittest.TestCase

    methods (TestMethodSetup)

        function addSourceToPath(~)

            addpath(EMUNetworkEnumeratorTest.sourcePath());

        end

    end

    methods (Test)

        function enumerateTraversesFromTargetToSubstrate(testCase)

            source = EMUNetworkEnumeratorTest.createSource(false);
            enumerator = openmebius.mfa.EMUNetworkEnumerator();

            result = enumerator.enumerate(source);

            testCase.verifyTrue(result.IsValid);
            testCase.verifyEmpty(result.ErrorMessages);
            testCase.verifyEqual( ...
                sort(result.TableEMU.EMU), ...
                sort(["T_{A}"; "A_{A}"; "S_{A}"]));
            testCase.verifyEqual(height(result.TableEMUReaction), 2);
            testCase.verifyEqual( ...
                sort(string(result.TableEMUReaction.RxnID)), ...
                sort(["T"; "r1"]));
            target = result.TableEMU(result.TableEMU.EMU == "T_{A}", :);
            substrate = result.TableEMU(result.TableEMU.EMU == "S_{A}", :);
            testCase.verifyTrue(target.Target);
            testCase.verifyFalse(substrate.Target);
            testCase.verifyNotEmpty(result.SearchedProducts);

        end

        function enumerateRejectsMultipleMSProducts(testCase)

            source = EMUNetworkEnumeratorTest.createSource(true);
            enumerator = openmebius.mfa.EMUNetworkEnumerator();

            result = enumerator.enumerate(source);

            testCase.verifyFalse(result.IsValid);
            testCase.verifyNotEmpty(result.ErrorMessages);
            testCase.verifyEmpty(result.TableEMU);
            testCase.verifyEmpty(result.TableEMUReaction);

        end

    end

    methods (Static, Access = private)

        function source = createSource(hasMultipleProducts)

            msProducts = {'T'};

            if hasMultipleProducts
                msProducts = {'T', 'U'};
            end

            msReactions = table( ...
                {{'A'}}, ...
                {msProducts}, ...
                VariableNames = ["Reactants", "Products"], ...
                RowNames = {'T'});
            msTransitions = table( ...
                {{'A'}}, ...
                {{'A'}}, ...
                VariableNames = ["Reactants", "Products"], ...
                RowNames = {'T'});
            reactions = table( ...
                {{'S'}}, ...
                {{'A'}}, ...
                VariableNames = ["Reactants", "Products"], ...
                RowNames = {'r1'});
            transitions = table( ...
                {{'A'}}, ...
                {{'A'}}, ...
                VariableNames = ["Reactants", "Products"], ...
                RowNames = {'r1'});
            metabolites = table( ...
                ["S"; "A"; "T"], ...
                ["substrate"; "metabolite"; "metabolite"], ...
                {false; false; false}, ...
                VariableNames = ["Metabolite", "Type", "Symmetric"]);
            source = openmebius.mfa.EMUNetworkSource( ...
                MSReactions = msReactions, ...
                MSTransitions = msTransitions, ...
                Reactions = reactions, ...
                Transitions = transitions, ...
                Metabolites = metabolites);

        end

        function path = sourcePath()

            path = fullfile( ...
                EMUNetworkEnumeratorTest.repositoryRoot(), ...
                "src");

        end

        function path = repositoryRoot()

            path = fileparts(fileparts(mfilename("fullpath")));

        end

    end

end
