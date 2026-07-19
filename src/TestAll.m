testDirectory = fullfile( ...
    fileparts(fileparts(mfilename("fullpath"))), "tests");
addpath(testDirectory);

runAllTests();
