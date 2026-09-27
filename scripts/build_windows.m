function build_windows(include_matlab)
%BUILD_WINDOWS Build and package DECTSim as a Windows standalone application.
%
% BUILD_WINDOWS() has the installer download MATLAB Runtime from the end
% user's own machine when they run it (a much smaller installer file,
% but it requires the end user's network to reach mathworks.com without
% interference, e.g. no SSL-inspecting proxy).
%
% BUILD_WINDOWS(true) instead bundles MATLAB Runtime into the installer
% itself, so end users don't need internet access at install time (a
% much larger installer file).
%
% Requirements:
%   - Windows
%   - MATLAB R2026a or newer
%   - MATLAB Compiler
%   - Image Processing Toolbox

    arguments
        include_matlab (1, 1) logical = false
    end

    rootDir = find_root_dir(fileparts(mfilename("fullpath")));
    guiDir = fullfile(rootDir, "gui");
    srcDir = fullfile(rootDir, "src");
    buildRoot = fullfile(rootDir, "build");
    applicationOutput = fullfile(buildRoot, "application");
    installerOutput = fullfile(buildRoot, "installer");

    assert(ispc, ...
        "DECTSim:UnsupportedPlatform", ...
        "A Windows executable must be built on Windows. Use build_unix.m on macOS/Linux.");

    assert(~isempty(which("compiler.build.standaloneWindowsApplication")), ...
        "DECTSim:MissingCompiler", ...
        "MATLAB Compiler is not available. " + ...
        "Install and license MATLAB Compiler before building.");

    assert(~isempty(which("fan2para")) && ~isempty(which("iradon")), ...
        "DECTSim:MissingImageProcessingToolbox", ...
        "Image Processing Toolbox is not available. " + ...
        "DECTSim requires it for reconstruction.");

    assert(isfile(fullfile(guiDir, "gui.m")), ...
        "DECTSim:MissingGUI", ...
        "Could not find gui/gui.m.");

    assert(isfolder(srcDir), ...
        "DECTSim:MissingSource", ...
        "Could not find the src directory.");

    if include_matlab
        % Fail fast, before the multi-minute mcc build below, since
        % compiler.runtime.download (needed to bundle MATLAB Runtime into
        % the installer) does not work at all on MATLAB Online, only on a
        % locally-installed MATLAB Compiler.
        ensure_runtime_downloadable();
    end

    licenseFile = fullfile(rootDir, "LICENSE");
    noticeFile = fullfile(rootDir, "NOTICE.txt");
    appLicenseFile = fullfile(rootDir, "APPLICATION_LICENSE.txt");

    assert(isfile(licenseFile) && isfile(noticeFile) && isfile(appLicenseFile), ...
        "DECTSim:MissingLicenseFiles", ...
        "Could not find LICENSE, NOTICE.txt and APPLICATION_LICENSE.txt in %s.", rootDir);

    % Make all DECTSim classes and functions visible during dependency analysis.
    originalPath = path;
    pathCleanup = onCleanup(@() path(originalPath));

    addpath(guiDir);
    addpath(genpath(srcDir));

    % Build any of the three DECTSim MEX functions that are missing
    % (photon_attenuation_mex, ray_trace_many_mex, ray_trace_mex).
    % material_attenuation and save_phantom_preview need
    % photon_attenuation_mex to generate the example data below.
    assert(~isempty(which("make_mex")), ...
        "DECTSim:MissingMakeMex", ...
        "Could not find make_mex.m. It should be in the same folder as build_windows.m.");
    make_mex();

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

        % run() changes the current folder to the script's own directory
        % before executing it. ExampleObjects.m saves to relative paths
        % such as "gui/PhantomExample1.mat", which assumes the current
        % folder is rootDir, not guiDir. Run from rootDir so either the
        % old relative-path version or a guiDir-based version works.
        originalDir = pwd;
        dirCleanup = onCleanup(@() cd(originalDir));
        cd(rootDir);

        run(fullfile(guiDir, "ExampleObjects.m"));

        clear dirCleanup
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

    if include_matlab
        runtimeDelivery = "installer";
    else
        runtimeDelivery = "web";
    end

    fprintf("Creating the Windows installer...\n");

    compiler.package.installer( ...
        buildResults, ...
        "ApplicationName", "DECTSim", ...
        "InstallerName", "DECTSimInstaller", ...
        "Version", "1.0.0", ...
        "Summary", ...
            "Dual-energy computed tomography simulation application.", ...
        "OutputDir", installerOutput, ...
        "RuntimeDelivery", runtimeDelivery, ...
        "AdditionalFiles", [licenseFile; noticeFile; appLicenseFile], ...
        "Verbose", "on");

    fprintf("\nDECTSim build completed successfully.\n");
    fprintf("Application output:\n  %s\n", applicationOutput);
    fprintf("Installer output:\n  %s\n", installerOutput);

    if include_matlab
        fprintf("\nNote: DECTSimInstaller.exe has MATLAB Runtime bundled " + ...
                "inside (no internet access needed at install time).\n");
    else
        fprintf("\nNote: DECTSimInstaller.exe downloads MATLAB Runtime at " + ...
                "install time (requires the end user's network to reach " + ...
                "mathworks.com).\n");
    end

    % Keep the onCleanup object alive until the function completes.
    clear pathCleanup
end

function ensure_runtime_downloadable()
    % RuntimeDelivery "installer" needs MATLAB Runtime cached locally on
    % this build machine (compiler.package.installer does not download it
    % automatically). compiler.runtime.list reports what is already
    % cached, so only download if the current release's runtime is
    % missing, since the download is large (multiple GB).
    assert(~isempty(which("compiler.runtime.download")), ...
        "DECTSim:MissingRuntimeDownloader", ...
        "compiler.runtime.download is not available. " + ...
        "Update MATLAB Compiler before building.");

    currentRelease = "R" + version("-release");

    try
        cachedRuntimes = compiler.runtime.list();
        alreadyCached = any(strcmp(string({cachedRuntimes.Release}), currentRelease));
    catch
        % If listing fails for any reason, fall back to attempting the
        % download, which is a no-op if already cached.
        alreadyCached = false;
    end

    if alreadyCached
        fprintf("MATLAB Runtime for %s is already cached.\n", currentRelease);
        return;
    end

    fprintf("Downloading MATLAB Runtime for %s (this may take a while)...\n", ...
        currentRelease);

    try
        compiler.runtime.download();
    catch downloadError
        error( ...
            "DECTSim:RuntimeDownloadUnavailable", ...
            "Could not download MATLAB Runtime for %s: %s\n\n" + ...
            "compiler.runtime.download does not work on MATLAB Online " + ...
            "(only with a MATLAB Compiler installed on your own machine). " + ...
            "Use build_windows() (the default, include_matlab=false) instead, " + ...
            "which has the installer download MATLAB Runtime on the end " + ...
            "user's own machine rather than bundling it here.", ...
            currentRelease, downloadError.message);
    end
end

function rootDir = find_root_dir(startDir)
    % Walk up from this script's folder until DECTSim.prj is found, so
    % build_windows.m works whether it lives at the repo root or in a
    % subfolder such as scripts/.
    rootDir = startDir;
    while ~isfile(fullfile(rootDir, "DECTSim.prj"))
        parentDir = fileparts(rootDir);
        assert(~strcmp(parentDir, rootDir), ...
            "DECTSim:RootNotFound", ...
            "Could not find DECTSim.prj above %s.", startDir);
        rootDir = parentDir;
    end
end
