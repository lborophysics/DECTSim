function rootDir = find_root_dir(startDir)
%FIND_ROOT_DIR Walk up from startDir until DECTSim.prj is found.
%   Lets build_unix.m/build_windows.m work from any subfolder, such as
%   scripts/, without depending on the current working directory.

    rootDir = startDir;
    while ~isfile(fullfile(rootDir, "DECTSim.prj"))
        parentDir = fileparts(rootDir);
        assert(~strcmp(parentDir, rootDir), ...
            "DECTSim:RootNotFound", "Could not find DECTSim.prj above %s.", startDir);
        rootDir = parentDir;
    end
end
