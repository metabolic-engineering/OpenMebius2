function results = runAllTests(options)
%RUNALLTESTS Run all profiles through the common test runner.

arguments
    options.ReportDirectory (1, 1) string = "test-results"
    options.Coverage (1, 1) logical = true
end

results = runTestProfile( ...
    "all", ...
    ReportDirectory = options.ReportDirectory, ...
    Coverage = options.Coverage);

end
