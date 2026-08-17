function results = runTestProfile(profile, options)
%RUNTESTPROFILE Run one test profile with optional reports and coverage.

arguments
    profile (1, 1) string {mustBeMember( ...
        profile, ["fast", "domain", "numerical", "integration", "all"])}
    options.ReportDirectory (1, 1) string = ""
    options.Coverage (1, 1) logical = false
end

root = string(fileparts(fileparts(mfilename("fullpath"))));
addpath(fullfile(root, "src"));
addpath(fullfile(root, "tests"));

suite = testProfileSuite(profile);
runner = matlab.unittest.TestRunner.withTextOutput;
reportDirectory = "";

if options.ReportDirectory ~= ""
    reportDirectory = fullfile(root, options.ReportDirectory);
    if ~isfolder(reportDirectory)
        mkdir(reportDirectory);
    end

    reportPath = fullfile(reportDirectory, profile + "-tests.xml");
    runner.addPlugin( ...
        matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
        reportPath));
end

if options.Coverage
    sourceDirectory = fullfile(root, "src");

    if reportDirectory == ""
        coveragePlugin = matlab.unittest.plugins.CodeCoveragePlugin ...
            .forFolder(sourceDirectory, IncludingSubfolders = true);
    else
        coveragePath = fullfile( ...
            reportDirectory, profile + "-coverage.xml");
        coverageFormat = matlab.unittest.plugins.codecoverage ...
            .CoberturaFormat(coveragePath);
        coveragePlugin = matlab.unittest.plugins.CodeCoveragePlugin ...
            .forFolder( ...
            sourceDirectory, ...
            IncludingSubfolders = true, ...
            Producing = coverageFormat);
    end

    runner.addPlugin(coveragePlugin);
end

results = runner.run(suite);
assertSuccess(results);

end
