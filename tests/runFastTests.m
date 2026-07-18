function results = runFastTests(options)
%RUNFASTTESTS Run the CI boundary suite without numerical integration tests.

arguments
    options.ReportDirectory (1, 1) string = ""
end

root = string(fileparts(fileparts(mfilename("fullpath"))));
addpath(fullfile(root, "src"));
addpath(fullfile(root, "tests"));

suite = ciFastTestSuite();
runner = matlab.unittest.TestRunner.withTextOutput;

if options.ReportDirectory ~= ""
    reportDirectory = fullfile(root, options.ReportDirectory);
    if ~isfolder(reportDirectory)
        mkdir(reportDirectory);
    end

    reportPath = fullfile(reportDirectory, "fast-tests.xml");
    plugin = matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
        reportPath);
    runner.addPlugin(plugin);
end

results = runner.run(suite);
assertSuccess(results);

end
