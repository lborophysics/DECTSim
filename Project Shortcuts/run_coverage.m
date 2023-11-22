import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageResult
suite = testsuite();
runner = testrunner('minimal');

format = CoverageResult;
p = CodeCoveragePlugin.forFolder("src","IncludingSubfolders",true,"Producing", format);

runner.addPlugin(p)

runner.run(suite)
filePath = generateHTMLReport(format.Result, "coverage_results","MainFile", "coverage.html");

open(filePath)