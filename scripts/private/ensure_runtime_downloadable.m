function ensure_runtime_downloadable(builderName)
%ENSURE_RUNTIME_DOWNLOADABLE Cache MATLAB Runtime locally for bundling.
%   Bundling MATLAB Runtime into an installer (RuntimeDelivery
%   "installer") needs it cached locally first. builderName names the
%   calling script (e.g. "build_unix") for the error message below.

    assert(~isempty(which("compiler.runtime.download")), ...
        "DECTSim:MissingRuntimeDownloader", "Update MATLAB Compiler before building.");

    currentRelease = "R" + version("-release");
    try
        cachedRuntimes = compiler.runtime.list();
        alreadyCached = any(strcmp(string({cachedRuntimes.Release}), currentRelease));
    catch
        alreadyCached = false;
    end

    if alreadyCached
        fprintf("MATLAB Runtime for %s is already cached.\n", currentRelease);
        return;
    end

    fprintf("Downloading MATLAB Runtime for %s (this may take a while)...\n", currentRelease);
    try
        compiler.runtime.download();
    catch downloadError
        error("DECTSim:RuntimeDownloadUnavailable", ...
            "Could not download MATLAB Runtime: %s\n" + ...
            "This does not work on MATLAB Online. Use %s() " + ...
            "(include_matlab=false) instead.", downloadError.message, builderName);
    end
end
