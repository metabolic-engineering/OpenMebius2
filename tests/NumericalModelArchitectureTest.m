classdef NumericalModelArchitectureTest < matlab.unittest.TestCase
    % NUMERICALMODELARCHITECTURETEST Guards the K1-K3 model boundary.

    methods (Test)
        function legacyNumericalClassesAreAbsent(testCase)
            root = NumericalModelArchitectureTest.repositoryRoot();

            testCase.verifyFalse(isfile(fullfile(root, "src", "EMUModel.m")));
            testCase.verifyFalse(isfile(fullfile(root, "src", "Stoichiometry.m")));

            files = dir(fullfile(root, "src", "**", "*.m"));
            forbidden = [ ...
                "classdef\s+EMUModel\b", ...
                "classdef\s+Stoichiometry\b", ...
                "<\s*Stoichiometry\b", ...
                "(?<![A-Za-z0-9_])EMUModel\s*\(" ...
            ];

            violations = strings(0, 1);
            for i = 1:numel(files)
                path = fullfile(files(i).folder, files(i).name);
                source = fileread(path);
                for pattern = forbidden
                    if ~isempty(regexp(source, pattern, "once"))
                        violations(end + 1, 1) = string(path); %#ok<AGROW>
                    end
                end
            end

            testCase.verifyEmpty(unique(violations));
        end

        function metabolicModelConstructorHasNoInfrastructureIO(testCase)
            source = fileread(fullfile( ...
                NumericalModelArchitectureTest.repositoryRoot(), ...
                "src", "+openmebius", "+application", "+model", ...
                "MetabolicModel.m"));

            testCase.verifyFalse(contains(source, "CacheRepository"));
            testCase.verifyFalse(contains(source, "ModelRepository"));
            testCase.verifyFalse(contains(source, "load("));
            testCase.verifyFalse(contains(source, "save("));
            testCase.verifyFalse(contains(source, "warning('off'"));
        end

        function repositoryOwnsWorkspaceAndCacheComposition(testCase)
            source = fileread(fullfile( ...
                NumericalModelArchitectureTest.repositoryRoot(), ...
                "src", "+openmebius", "+infrastructure", "+model", ...
                "ModelRepository.m"));

            testCase.verifyTrue(contains(source, ...
                "openmebius.application.model.ModelWorkspace("));
            testCase.verifyTrue(contains(source, ...
                "StoichiometricNetworkFactory.create(workspace)"));
            testCase.verifyTrue(contains(source, ...
                "openmebius.application.model.MetabolicModel("));
            testCase.verifyTrue(contains(source, ...
                "obj.CacheRepository.load("));
            testCase.verifyTrue(contains(source, ...
                "obj.CacheRepository.save("));
        end
    end

    methods (Static, Access = private)
        function path = repositoryRoot()
            path = fileparts(fileparts(mfilename("fullpath")));
        end
    end
end
