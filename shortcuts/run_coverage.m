import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageResult

proj = currentProject;
proj_path = proj.ProjectStartupFolder;

suite = testsuite("BaseFolder", strcat(proj_path, "/tests"), "IncludeReferencedProjects",true);
runner = testrunner('minimal');

format = CoverageResult;
p = CodeCoveragePlugin.forFolder(strcat(proj_path, "/src"), "IncludingSubfolders", true, "Producing", format);

runner.addPlugin(p)

runner.run(suite)
filePath = generateHTMLReport(format.Result, "coverage_results","MainFile", "coverage.html");

open(filePath)