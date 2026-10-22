function build_windows()
%BUILD_WINDOWS Build and package DECTSim as a Windows standalone application.
%
% Requirements:
%   - Windows
%   - MATLAB R2026a or newer
%   - MATLAB Compiler
%   - Image Processing Toolbox

    rootDir = fileparts(mfilename("fullpath"));
    guiDir = fullfile(rootDir, "gui");
    srcDir = fullfile(rootDir, "src");
    buildRoot = fullfile(rootDir, "build");
    applicationOutput = fullfile(buildRoot, "application");
    installerOutput = fullfile(buildRoot, "installer");

    assert(ispc, ...
        "DECTSim:UnsupportedPlatform", ...
        "A Windows executable must be built on Windows.");

    assert(~isempty(which("compiler.build.standaloneWindowsApplication")), ...
        "DECTSim:MissingCompiler", ...
        ["MATLAB Compiler is not available. " ...
         "Install and license MATLAB Compiler before building."]);

    assert(~isempty(which("fan2para")) && ~isempty(which("iradon")), ...
        "DECTSim:MissingImageProcessingToolbox", ...
        ["Image Processing Toolbox is not available. " ...
         "DECTSim requires it for reconstruction."]);

    assert(isfile(fullfile(guiDir, "gui.m")), ...
        "DECTSim:MissingGUI", ...
        "Could not find gui/gui.m.");

    assert(isfolder(srcDir), ...
        "DECTSim:MissingSource", ...
        "Could not find the src directory.");

    % Make all DECTSim classes and functions visible during dependency analysis.
    originalPath = path;
    pathCleanup = onCleanup(@() path(originalPath));

    addpath(guiDir);
    addpath(genpath(srcDir));

    requiredDataNames = [
        "PhantomExample1.mat"
        "PhantomExample1.png"
        "PhantomExample2.mat"
        "PhantomExample2.png"
        "PhantomExample3.mat"
        "PhantomExample3.png"
        "PhantomExample4.mat"
        "PhantomExample4.png"
        "SourceExample40kvp.mat"
        "SourceExample80kvp.mat"
    ];

    requiredDataFiles = fullfile(guiDir, requiredDataNames);

    % Generate the bundled example objects when they do not yet exist.
    if any(~isfile(requiredDataFiles))
        fprintf("Generating missing DECTSim example data...\n");
        run(fullfile(guiDir, "ExampleObjects.m"));
    end

    missingData = requiredDataFiles(~isfile(requiredDataFiles));

    if ~isempty(missingData)
        error( ...
            "DECTSim:MissingExampleData", ...
            "The following example files were not generated:\n%s", ...
            strjoin(missingData, newline));
    end

    % Start each build with clean output directories.
    if isfolder(buildRoot)
        rmdir(buildRoot, "s");
    end

    mkdir(applicationOutput);
    mkdir(installerOutput);

    additionalApplicationFiles = [
        fullfile(guiDir, "graphics")
        fullfile(guiDir, "40kvp.spk")
        fullfile(guiDir, "80kvp.spk")
        requiredDataFiles(:)
        srcDir
    ];

    fprintf("Building the standalone Windows application...\n");

    buildResults = compiler.build.standaloneWindowsApplication( ...
        fullfile(guiDir, "gui.m"), ...
        "ExecutableName", "DECTSim", ...
        "ExecutableVersion", "1.0.0.0", ...
        "OutputDir", applicationOutput, ...
        "AdditionalFiles", additionalApplicationFiles, ...
        "AutoDetectDataFiles", "on", ...
        "Verbose", "on");

    fprintf("Creating the Windows installer...\n");

    compiler.package.installer( ...
        buildResults, ...
        "ApplicationName", "DECTSim", ...
        "InstallerName", "DECTSimInstaller", ...
        "Version", "1.0.0", ...
        "Summary", ...
            "Dual-energy computed tomography simulation application.", ...
        "OutputDir", installerOutput, ...
        "RuntimeDelivery", "web", ...
        "AdditionalFiles", [...
                                fullfile(rootDir, "LICENSE")
                                fullfile(rootDir, "NOTICE.txt")
                                fullfile(rootDir, "APPLICATION_LICENSE.txt")
                            ],"Verbose", "on");

    fprintf("\nDECTSim build completed successfully.\n");
    fprintf("Application output:\n  %s\n", applicationOutput);
    fprintf("Installer output:\n  %s\n", installerOutput);

    % Keep the onCleanup object alive until the function completes.
    clear pathCleanup
end
