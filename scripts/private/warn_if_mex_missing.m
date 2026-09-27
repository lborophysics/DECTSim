function warn_if_mex_missing(rootDir)
%WARN_IF_MEX_MISSING Warn (but don't fail) if the prebuilt MEX files are absent.
%   MEX files speed up the app but are not required: material_attenuation
%   and ray_trace_many fall back to pure MATLAB when missing. They are
%   prebuilt and committed to the repo per platform (see
%   scripts/make_mex.m) rather than built during build_unix.m/
%   build_windows.m, since that build machine may not have a MATLAB
%   Coder license.

    mexFiles = [
        fullfile(rootDir, "src", "materials", "photon_attenuation_mex")
        fullfile(rootDir, "src", "ray_tracing", "ray_trace_many_mex")
        fullfile(rootDir, "src", "ray_tracing", "ray_trace_mex")
    ] + "." + mexext;

    missingMex = mexFiles(~isfile(mexFiles));
    if ~isempty(missingMex)
        warning("DECTSim:MexFilesMissing", ...
            "The app will still work, just slower, without these prebuilt " + ...
            "MEX files:\n%s", strjoin(missingMex, newline));
    end
end
