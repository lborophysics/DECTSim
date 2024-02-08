import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageResult
suite = testsuite();
runner = testrunner('minimal');

% get all m-code files under the folder
out_dir = dir(fullfile("src", '**', '*.m'));
mfile_paths = string({out_dir.folder}) + filesep + string({out_dir.name});
% remove files to exclude
mfile_paths(contains(mfile_paths, filesep+"misc"+filesep)) = [];

format = CoverageResult;
p = CodeCoveragePlugin.forFile(mfile_paths,"Producing", format);

runner.addPlugin(p)

runner.run(suite)
filePath = generateHTMLReport(format.Result, "coverage_results","MainFile", "coverage.html");

open(filePath)