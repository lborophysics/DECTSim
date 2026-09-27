# DECTSim First-Time Setup

DECTSim can be run in three ways:

1. As an installed Windows application.
2. From the source code in MATLAB Desktop.
3. From the source code in MATLAB Online.

---

## 1. Windows application

The Windows application does not require a MATLAB licence. It cannot be used to modify or debug the DECTSim source code, run exported MATLAB scripts, or add new MATLAB functions and classes. Users requiring these capabilities should run the source-code version in MATLAB Desktop or MATLAB Online.

### Install


1. Open the DECTSim **Releases** page on GitHub.
2. Open the latest release.
3. Under **Assets**, download:

   `DECTSim-Windows.zip`

4. Do not download the file labelled **Source code**, as that contains
   the MATLAB source rather than the Windows application.
5. Extract the downloaded ZIP file.

6. Run:

   ```text
   DECTSimInstaller.exe
   ```

7. Follow the installer instructions.

8. Allow the installer to install MATLAB Runtime when prompted.

### Run

After installation, open **DECTSim** from the Windows Start menu or desktop shortcut.

When the application opens, leave the settings at their defaults and click:

```text
Run
```

The simulation results will appear in the Results panel.

You do not need to run the installer again after DECTSim has been installed.

---

## 2. MATLAB Desktop

The source-code version requires MATLAB and Image Processing Toolbox.

### Download the source code

Clone or download the DECTSim repository.

The main repository folder should contain:

```text
DECTSim.prj
gui/
src/
```

### Open the project

1. Start MATLAB.
2. Open the local DECTSim folder.
3. Double-click:

   ```text
   DECTSim.prj
   ```

Alternatively, run:

```matlab
project = openProject("C:\path\to\DECTSim\DECTSim.prj");
```

Replace the example path with the location of your DECTSim folder.

### Create the example files

The following files are required by the application:

```text
gui/PhantomExample1.mat
gui/PhantomExample2.mat
gui/PhantomExample3.mat
gui/PhantomExample4.mat
gui/SourceExample40kvp.mat
gui/SourceExample80kvp.mat
```

When these files are missing, run:

```matlab
root = string(project.RootFolder);

addpath(fullfile(root, "gui"));
addpath(genpath(fullfile(root, "src")));

run(fullfile(root, "gui", "ExampleObjects.m"));
```

This normally only needs to be done once after downloading the repository.

### Run DECTSim

In the MATLAB Command Window, run:

```matlab
app = gui;
```

When the application opens, leave the settings at their defaults and click:

```text
Run
```

For later sessions:

1. Open `DECTSim.prj`.
2. Run `app = gui`.

---

## 3. MATLAB Online

The source-code version requires access to MATLAB Online and Image Processing Toolbox.

The compiled Windows application cannot be run in MATLAB Online.

### Clone the repository

1. Open MATLAB Online.

2. Select **Home > New > Git Clone**.

3. Enter the repository URL:

   ```text
   https://github.com/lborophysics/DECTSim.git
   ```

4. Select **Clone**.

Alternatively, run:

```matlab
gitclone("https://github.com/lborophysics/DECTSim.git", "DECTSim");
cd("DECTSim");
```

### Open the project

Double-click:

```text
DECTSim.prj
```

Alternatively, run:

```matlab
project = openProject("DECTSim.prj");
```

### Create the example files

Run:

```matlab
root = string(project.RootFolder);

addpath(fullfile(root, "gui"));
addpath(genpath(fullfile(root, "src")));

run(fullfile(root, "gui", "ExampleObjects.m"));
```

This normally only needs to be done once.

### Run DECTSim

Run:

```matlab
app = gui;
```

When the application opens, leave the settings at their defaults and click:

```text
Run
```

