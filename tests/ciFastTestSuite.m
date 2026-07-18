function [suite, testFiles] = ciFastTestSuite()
%CIFASTTESTSUITE Build the deterministic boundary test suite used by CI.

import matlab.unittest.TestSuite

testDirectory = string(fileparts(mfilename("fullpath")));
patterns = ["*BoundaryTest.m", "*ContextTest.m"];
testFiles = strings(0, 1);

for pattern = patterns
    matches = dir(fullfile(testDirectory, pattern));
    matchNames = sort(string({matches.name}));

    for matchIndex = 1:numel(matchNames)
        testFiles(end + 1, 1) = fullfile( ...
            testDirectory, matchNames(matchIndex)); %#ok<AGROW>
    end
end

requiredTests = [ ...
    "CIFastTestSuiteTest.m"; ...
    "MainAppCompositionRootTest.m"; ...
    "MainApplicationSessionTest.m"; ...
    "OpenMebius2SourceSyncTest.m"];

for requiredTest = requiredTests'
    testPath = fullfile(testDirectory, requiredTest);
    if ~isfile(testPath)
        error( ...
            "OpenMebius2:Test:MissingCITest", ...
            "Required CI test is missing: %s", ...
            testPath);
    end
    testFiles(end + 1, 1) = testPath; %#ok<AGROW>
end

testFiles = unique(testFiles, "stable");
if isempty(testFiles)
    error( ...
        "OpenMebius2:Test:EmptyCITestSuite", ...
        "No tests were selected for the CI fast test suite.");
end

suite = TestSuite.fromFile(testFiles(1));
for testIndex = 2:numel(testFiles)
    suite = [suite, TestSuite.fromFile(testFiles(testIndex))]; %#ok<AGROW>
end

end
