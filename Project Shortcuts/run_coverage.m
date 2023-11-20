import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageResult
suite = testsuite();
runner = testrunner('minimal');

format1 = CoverageResult;
format2 = CoverageResult;
p1 = CodeCoveragePlugin.forFolder("Classes","IncludingSubfolders",true,"Producing", format1);
p2 = CodeCoveragePlugin.forFolder("Functions","IncludingSubfolders",true,"Producing", format2);

runner.addPlugin(p1)
runner.addPlugin(p2)

runner.run(suite)
result = format1.Result + format2.Result;
filePath = generateHTMLReport(result, "coverage_results","MainFile", "coverage.html");

open(filePath)