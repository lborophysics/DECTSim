function build_windows(include_matlab)
%BUILD_WINDOWS Build and package DECTSim as a Windows standalone application.
%   BUILD_WINDOWS() has the installer download MATLAB Runtime at install
%   time (smaller file, needs the end user's network).
%   BUILD_WINDOWS(true) bundles MATLAB Runtime into the installer (larger
%   file, works offline).

    arguments
        include_matlab (1, 1) logical = false
    end

    rootDir = find_root_dir(fileparts(mfilename("fullpath")));
    guiDir = fullfile(rootDir, "gui");
    srcDir = fullfile(rootDir, "src");
    buildRoot = fullfile(rootDir, "build");
    applicationOutput = fullfile(buildRoot, "application");
    installerOutput = fullfile(buildRoot, "installer");

    assert(ispc, "DECTSim:UnsupportedPlatform", "Use build_unix.m on macOS/Linux.");
    assert(~isempty(which("compiler.build.standaloneWindowsApplication")), ...
        "DECTSim:MissingCompiler", "MATLAB Compiler is required.");
    assert(~isempty(which("fan2para")) && ~isempty(which("iradon")), ...
        "DECTSim:MissingImageProcessingToolbox", "Image Processing Toolbox is required.");
    assert(isfile(fullfile(guiDir, "gui.m")), "DECTSim:MissingGUI", "Could not find gui/gui.m.");
    assert(isfolder(srcDir), "DECTSim:MissingSource", "Could not find the src directory.");

    if include_matlab
        % Fail before the multi-minute mcc build below: this doesn't work
        % on MATLAB Online, only with a locally-installed MATLAB Compiler.
        ensure_runtime_downloadable("build_windows");
    end

    licenseFile = fullfile(rootDir, "LICENSE");
    noticeFile = fullfile(rootDir, "NOTICE.txt");
    appLicenseFile = fullfile(rootDir, "APPLICATION_LICENSE.txt");
    assert(isfile(licenseFile) && isfile(noticeFile) && isfile(appLicenseFile), ...
        "DECTSim:MissingLicenseFiles", ...
        "Could not find LICENSE, NOTICE.txt and APPLICATION_LICENSE.txt in %s.", rootDir);

    originalPath = path;
    pathCleanup = onCleanup(@() path(originalPath));
    addpath(guiDir);
    addpath(genpath(srcDir));

    % MEX files speed up the app but are not required: material_attenuation
    % and ray_trace_many fall back to pure MATLAB when missing. They are
    % prebuilt and committed to the repo (see scripts/make_mex.m) rather
    % than built here, since this build machine may not have a MATLAB
    % Coder license.
    warn_if_mex_missing(rootDir);

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

    if any(~isfile(requiredDataFiles))
        fprintf("Generating missing DECTSim example data...\n");

        % run() changes to the script's own folder before executing it,
        % but ExampleObjects.m saves to paths relative to rootDir.
        originalDir = pwd;
        dirCleanup = onCleanup(@() cd(originalDir));
        cd(rootDir);
        run(fullfile(guiDir, "ExampleObjects.m"));
        clear dirCleanup
    end

    missingData = requiredDataFiles(~isfile(requiredDataFiles));
    if ~isempty(missingData)
        error("DECTSim:MissingExampleData", ...
            "The following example files were not generated:\n%s", strjoin(missingData, newline));
    end

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
        "Summary", "Dual-energy computed tomography simulation application.", ...
        "OutputDir", installerOutput, ...
        "RuntimeDelivery", runtimeDelivery, ...
        "AdditionalFiles", [licenseFile; noticeFile; appLicenseFile], ...
        "Verbose", "on");

    fprintf("\nDECTSim build completed successfully.\n");
    fprintf("Application output:\n  %s\n", applicationOutput);
    fprintf("Installer output:\n  %s\n", installerOutput);

    if include_matlab
        runtimeNote = "MATLAB Runtime bundled inside (no internet needed to install)";
    else
        runtimeNote = "MATLAB Runtime downloaded at install time (needs internet access)";
    end
    fprintf("\nRun DECTSimInstaller.exe to install DECTSim (%s).\n", runtimeNote);

    clear pathCleanup
end
