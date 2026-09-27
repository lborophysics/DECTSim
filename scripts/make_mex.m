function make_mex(force)
%MAKE_MEX Build any missing DECTSim MEX functions with MATLAB Coder.
%
% MAKE_MEX() builds only the MEX functions that are not already present,
% leaving existing ones alone.
%
% MAKE_MEX(true) rebuilds all three regardless of whether they already
% exist.
%
% Per docs/source/dev_guide/intro.md, three files are ready to be built
% into MEX functions, each speeding up its pure-MATLAB counterpart:
%   - src/materials/photon_attenuation.m
%   - src/ray_tracing/ray_trace_many.m
%   - src/ray_tracing/ray_trace.m (backup path, only used in tests)
%
% Argument types below mirror the "Example code to run the function"
% comment block at the bottom of each file.
%
% Requirements:
%   - MATLAB Coder

    arguments
        force (1, 1) logical = false
    end

    rootDir = find_root_dir(fileparts(mfilename("fullpath")));

    assert(~isempty(which("codegen")), ...
        "DECTSim:MissingCoder", ...
        "MATLAB Coder is not available. " + ...
        "Install and license MATLAB Coder before building.");

    build_photon_attenuation(rootDir, force);
    build_ray_trace_many(rootDir, force);
    build_ray_trace(rootDir, force);
end

function rootDir = find_root_dir(startDir)
    % Walk up from this script's folder until DECTSim.prj is found, so
    % make_mex.m works whether it lives at the repo root or in a
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

function build_photon_attenuation(rootDir, force)
    materialsDir = fullfile(rootDir, "src", "materials");
    srcFile = fullfile(materialsDir, "photon_attenuation.m");
    assert(isfile(srcFile), "DECTSim:MissingSource", "Could not find %s.", srcFile);

    % Z, fracs are double(1x:100); density is double(1x1); nrj is double(1x:inf)
    zType       = coder.typeof(0, [1, 100], [false, true]);
    fracsType   = coder.typeof(0, [1, 100], [false, true]);
    densityType = coder.typeof(0, [1, 1]);
    nrjType     = coder.typeof(0, [1, Inf], [false, true]);

    build_mex(materialsDir, srcFile, "photon_attenuation_mex", ...
        {zType, fracsType, densityType, nrjType}, force);
end

function build_ray_trace_many(rootDir, force)
    rayTracingDir = fullfile(rootDir, "src", "ray_tracing");
    srcFile = fullfile(rayTracingDir, "ray_trace_many.m");
    assert(isfile(srcFile), "DECTSim:MissingSource", "Could not find %s.", srcFile);

    % ray_start, v1_to_v2 are double(3x:inf); init_plane, v_dims, num_planes are double(3x1)
    rayStartType  = coder.typeof(0, [3, Inf], [false, true]);
    v1ToV2Type    = coder.typeof(0, [3, Inf], [false, true]);
    initPlaneType = coder.typeof(0, [3, 1]);
    vDimsType     = coder.typeof(0, [3, 1]);
    numPlanesType = coder.typeof(0, [3, 1]);

    build_mex(rayTracingDir, srcFile, "ray_trace_many_mex", ...
        {rayStartType, v1ToV2Type, initPlaneType, vDimsType, numPlanesType}, force);
end

function build_ray_trace(rootDir, force)
    rayTracingDir = fullfile(rootDir, "src", "ray_tracing");
    srcFile = fullfile(rayTracingDir, "ray_trace.m");
    assert(isfile(srcFile), "DECTSim:MissingSource", "Could not find %s.", srcFile);

    % All inputs are double(3x1)
    vec3Type = coder.typeof(0, [3, 1]);

    build_mex(rayTracingDir, srcFile, "ray_trace_mex", ...
        {vec3Type, vec3Type, vec3Type, vec3Type, vec3Type}, force);
end

function build_mex(outputDir, srcFile, mexName, argTypes, force)
    mexFile = fullfile(outputDir, mexName + "." + string(mexext));

    if isfile(mexFile) && ~force
        fprintf("%s already exists, skipping.\n", mexFile);
        return;
    end

    cfg = coder.config("mex");
    cfg.IntegrityChecks = false;
    cfg.ResponsivenessChecks = false;

    % Build from outputDir so the mex lands next to its source file, where
    % the calling code expects to find it on the path (exist(..., 'file')).
    originalDir = pwd;
    dirCleanup = onCleanup(@() cd(originalDir));
    cd(outputDir);

    fprintf("Generating %s...\n", mexName);

    codegen(srcFile, ...
        "-config", cfg, ...
        "-o", mexName, ...
        "-args", argTypes);

    clear dirCleanup

    assert(isfile(mexFile), ...
        "DECTSim:MexBuildFailed", ...
        "codegen did not produce %s.", mexFile);

    fprintf("Built %s\n", mexFile);
end
