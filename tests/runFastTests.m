function results = runFastTests(options)
%RUNFASTTESTS Run the CI boundary suite without numerical integration tests.

arguments
    options.ReportDirectory (1, 1) string = ""
end

results = runTestProfile( ...
    "fast", ReportDirectory = options.ReportDirectory);

end
