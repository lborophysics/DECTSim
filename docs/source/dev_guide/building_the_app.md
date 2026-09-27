# Building the Standalone Application

This page is for anyone with a **MATLAB license that includes MATLAB Compiler** who wants to build the standalone DECTSim application (the same kind of `.exe`/installer described in [First-Time Setup](../user_guide/first_run.md)) themselves, for example to produce a new release, or to test a change to the GUI in compiled form.

## Requirements

- MATLAB R2026a or newer, with a license that includes:
  - **MATLAB Compiler** (required — builds the standalone app and installer)
  - **Image Processing Toolbox** (required — DECTSim uses it for reconstruction)
  - **MATLAB Coder** (optional — only needed if you also want to rebuild the MEX speed-ups, see [below](#rebuilding-the-mex-files))

**This must be a real, licensed, desktop MATLAB installation.** It does not work on MATLAB Online, and it does not work with the free MATLAB license that GitHub Actions' `matlab-actions/setup-matlab` grants automatically for public repositories — neither of those include MATLAB Compiler. This is also why DECTSim's release build is not automated in CI: someone with an institutional or personal MATLAB Compiler license needs to run these scripts locally and upload the results to a GitHub Release by hand.

## Running the build

The build scripts live in [`scripts/`](https://github.com/lborophysics/DECTSim/tree/main/scripts):

- `build_unix.m` — builds for macOS or Linux (run on that platform's own MATLAB)
- `build_windows.m` — builds for Windows

From the MATLAB Command Window, with the repository as your current folder (or anywhere — both scripts find the repository root automatically):

```matlab
build_unix        % macOS/Linux
build_windows      % Windows
```

Each takes one optional argument, `include_matlab`, controlling how the installer delivers MATLAB Runtime to end users:

```matlab
build_unix(false)   % default: installer downloads MATLAB Runtime when the end user installs it (smaller file, needs their network to reach mathworks.com)
build_unix(true)    % bundles MATLAB Runtime into the installer itself (much larger file, but works fully offline)
```

`include_matlab=true` needs MATLAB Runtime cached on your build machine first, via `compiler.runtime.download()` — the script does this automatically, but note this also does not work on MATLAB Online.

## Output

Both scripts write to a `build/` folder at the repository root:

- `build/application/` — the standalone app itself, plus a generic `readme.txt` and `run_*.sh`/`.exe` that MATLAB Compiler generates automatically
- `build/installer/` — the packaged installer end users actually run: `DECTSimInstaller.exe` on Windows, or a self-extracting `DECTSimInstaller.install` on macOS/Linux

To publish a release, zip up `build/installer/` (or just attach the installer file directly) as a GitHub Release asset.

## Rebuilding the MEX files

`photon_attenuation`, `ray_trace_many`, and `ray_trace` each have a compiled MEX counterpart (`photon_attenuation_mex`, etc.) that makes DECTSim significantly faster. These are optional: `material_attenuation` and `ray_trace_many` both fall back automatically to a pure-MATLAB implementation if their MEX file isn't present, so the app still works correctly without them, just more slowly.

`build_unix.m`/`build_windows.m` do **not** build these themselves — they only check whether they already exist (in `src/materials/` and `src/ray_tracing/`) and warn if they're missing, rather than trying to compile them, since that needs a MATLAB Coder license which is even less commonly available than a Compiler-only license.

If you do have MATLAB Coder, you can build (or rebuild) all three with:

```matlab
make_mex           % builds only the ones that don't already exist
make_mex(true)     % rebuilds all three, even if already present
```

This is also available as a manual alternative to the MATLAB Coder app described in [Creating the mex files](intro.md#creating-the-mex-files).

MEX files are platform- and architecture-specific (`.mexa64` for Linux, `.mexw64` for Windows, `.mexmaci64`/`.mexmaca64` for Intel/Apple Silicon Mac). Several platforms' files can sit side-by-side in the same folder with no conflict — MATLAB automatically picks the one matching the machine it's currently running on. If you build and commit one for a platform, it will automatically start being used by anyone (or any CI job) running on that platform, with no other configuration needed.
