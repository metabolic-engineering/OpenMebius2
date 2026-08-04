function [suite, testFiles] = testProfileSuite(profile)
%TESTPROFILESUITE Build a MATLAB test suite for an OpenMebius2 profile.

import matlab.unittest.TestSuite

root = string(fileparts(fileparts(mfilename("fullpath"))));
addpath(fullfile(root, "src"));
addpath(fullfile(root, "tests"));

testFiles = testProfileFiles(profile);
suite = TestSuite.fromFile(testFiles(1));

for testIndex = 2:numel(testFiles)
    suite = [suite, TestSuite.fromFile(testFiles(testIndex))]; %#ok<AGROW>
end

end
