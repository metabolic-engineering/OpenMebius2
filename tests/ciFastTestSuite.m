function [suite, testFiles] = ciFastTestSuite()
%CIFASTTESTSUITE Compatibility entry point for the CI fast profile.

[suite, testFiles] = testProfileSuite("fast");

end
