classdef gui < matlab.apps.AppBase
    %GUI DECTSim GUI
    %   The GUI for DECTSim program

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        FileMenu                        matlab.ui.container.Menu
        RunMenu                         matlab.ui.container.Menu
        LoadStateMenu                   matlab.ui.container.Menu
        SaveStateMenu                   matlab.ui.container.Menu
        ExportMenu                      matlab.ui.container.Menu
        ResetMenu                       matlab.ui.container.Menu
        HelpMenu                        matlab.ui.container.Menu
        DocumentationMenu               matlab.ui.container.Menu
        TabGroup                        matlab.ui.container.TabGroup
        RunTab                          matlab.ui.container.Tab
        ImagePanel                      matlab.ui.container.Panel
        PhantomImage                    matlab.ui.control.Image
        NumberofRotationsLabel          matlab.ui.control.Label
        ScatterPanel                    matlab.ui.container.Panel
        ScatterFactorSpinner            matlab.ui.control.Spinner
        ScatterFactorSpinnerLabel       matlab.ui.control.Label
        ScatterTypeListBox              matlab.ui.control.ListBox
        ScatterTypeListBoxLabel         matlab.ui.control.Label
        ScatterImage                    matlab.ui.control.Image
        NumberofRotationsEditField      matlab.ui.control.NumericEditField
        RunButton                       matlab.ui.control.Button
        DetectorArrayImage              matlab.ui.control.Image
        PCImage                         matlab.ui.control.Image
        WireImage                       matlab.ui.control.Image
        SourceImage                     matlab.ui.control.Image
        DistToDetectorUnits             matlab.ui.control.DropDown
        DistToDetectorField             matlab.ui.control.NumericEditField
        DistToDetectorLabel             matlab.ui.control.Label
        ClickonanobjecttochangeitLabel  matlab.ui.control.Label
        RotationImage                   matlab.ui.control.Image
        RaysImage                       matlab.ui.control.Image
        DistToDetectorLine              matlab.ui.control.Image
        SourcePanel                     matlab.ui.container.Panel
        Source2DropDown                 matlab.ui.control.DropDown
        Source2DropDownLabel            matlab.ui.control.Label
        SourceLoadButton                matlab.ui.control.Button
        Source1DropDown                 matlab.ui.control.DropDown
        Source1DropDownLabel            matlab.ui.control.Label
        SourceTypeDropDown              matlab.ui.control.DropDown
        SourceTypeDropDownLabel         matlab.ui.control.Label
        PhantomPanel                    matlab.ui.container.Panel
        VoxelSizeUnits                  matlab.ui.control.DropDown
        VoxelSizeEditField              matlab.ui.control.NumericEditField
        VoxelSizeEditFieldLabel         matlab.ui.control.Label
        PhantomLoadButton               matlab.ui.control.Button
        PhantomListBox                  matlab.ui.control.ListBox
        PhantomListBoxLabel             matlab.ui.control.Label
        DetectorPanel                   matlab.ui.container.Panel
        DetectorShapeDropDown           matlab.ui.control.DropDown
        DetectorShapeDropDownLabel      matlab.ui.control.Label
        NumberofPixelsEditField         matlab.ui.control.NumericEditField
        NumberofPixelsEditFieldLabel    matlab.ui.control.Label
        PixelWidthUnits                 matlab.ui.control.DropDown
        PixelWidthField                 matlab.ui.control.NumericEditField
        PixelWidthLabel                 matlab.ui.control.Label
        SensorTypeDropDown              matlab.ui.control.DropDown
        SensorTypeDropDownLabel         matlab.ui.control.Label
        ResultsPanel                    matlab.ui.container.Panel
        ShowDropDown                    matlab.ui.control.DropDown
        ShowDropDownLabel               matlab.ui.control.Label
        ReconstructedImageLabel         matlab.ui.control.Label
        Label                           matlab.ui.control.Label
        ReconstructionImage             matlab.ui.control.Image
        UIAxes                          matlab.ui.control.UIAxes
        ReconstructionPanel             matlab.ui.container.Panel
        InterpolationDropDown           matlab.ui.control.DropDown
        InterpolationDropDownLabel      matlab.ui.control.Label
        FilterListBox                   matlab.ui.control.ListBox
        FilterListBoxLabel              matlab.ui.control.Label
        RunContextMenu                  matlab.ui.container.ContextMenu
        LoadStateInContextMenu          matlab.ui.container.Menu
        SaveStateInContextMenu          matlab.ui.container.Menu
        RunInContextMenu                matlab.ui.container.Menu
        ResetInContextMenu              matlab.ui.container.Menu
        ExporttoScriptMenu              matlab.ui.container.Menu
        DetectorContextMenu             matlab.ui.container.ContextMenu
        DetectorHelpMenu_run            matlab.ui.container.Menu
        PhantomContextMenu              matlab.ui.container.ContextMenu
        LoadPhantomMenu                 matlab.ui.container.Menu
        PhantomHelpMenu_run             matlab.ui.container.Menu
        SourceContextMenu               matlab.ui.container.ContextMenu
        LoadSourceMenu                  matlab.ui.container.Menu
        SourceHelpMenu_run              matlab.ui.container.Menu
        ReconImageContextMenu           matlab.ui.container.ContextMenu
        RunSimulationMenu               matlab.ui.container.Menu
        ReconSaveImageasMenu            matlab.ui.container.Menu
        ReconstructionMenu              matlab.ui.container.Menu
        SinogramMenu                    matlab.ui.container.Menu
        ReconOpeninNewWindowMenu        matlab.ui.container.Menu
        ReconstructionMenu_2            matlab.ui.container.Menu
        SinogramMenu_2                  matlab.ui.container.Menu
        OpeninImageViewerMenu           matlab.ui.container.Menu
        ReconstructionMenu_3            matlab.ui.container.Menu
        SinogramMenu_3                  matlab.ui.container.Menu
        ReconImageHelpMenu              matlab.ui.container.Menu
        ReconstructionContextMenu       matlab.ui.container.ContextMenu
        ReconstructionHelpMenu          matlab.ui.container.Menu
        ScatterContextMenu              matlab.ui.container.ContextMenu
        ScatterHelpMenu                 matlab.ui.container.Menu
    end

    
    properties (Access = private)
        recon_fig    % If the reconstruction figure is open this is a handle
        sinogram_fig % If the sinogram figure is open this is a handle

        recons = {[]} % A way to store the most recent reconstruction 
        source_files = {'SourceExample40kvp.mat', 'SourceExample80kvp.mat'}
        phantom_files = {'PhantomExample1.mat', 'PhantomExample2.mat', 'PhantomExample3.mat', 'PhantomExample4.mat'}
    end

    methods (Access = private, Static)
        function colourImage = greyToColour(image)
            colourImage = cat(3, image, image, image);
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Image clicked function: RaysImage, SourceImage
        function ToggleSourcePanelVisibility(app, ~)
            if strcmp(app.SourcePanel.Visible, 'off')
                app.SourcePanel.Visible = 'on';
            else
                app.SourcePanel.Visible = 'off';
            end
        end

        % Image clicked function: PhantomImage
        function TogglePhantomPanelVisibility(app, ~)
            if strcmp(app.PhantomPanel.Visible, 'off')
                app.PhantomPanel.Visible = 'on';
            else
                app.PhantomPanel.Visible = 'off';
            end
        end

        % Image clicked function: DetectorArrayImage
        function ToggleDetectorPanelVisibility(app, ~)
            if strcmp(app.DetectorPanel.Visible, 'off')
                app.DetectorPanel.Visible = 'on';
            else
                app.DetectorPanel.Visible = 'off';
            end
        end

        % Image clicked function: PCImage, WireImage
        function ToggleReconstructionPanelVisibility(app, ~)
            if strcmp(app.ReconstructionPanel.Visible, 'off')
                app.ReconstructionPanel.Visible = 'on';
            else
                app.ReconstructionPanel.Visible = 'off';
            end
        end

        % Image clicked function: ScatterImage
        function ToggleScatterPanelVisibility(app, ~)
            if strcmp(app.ScatterPanel.Visible, 'off')
                app.ScatterPanel.Visible = 'on';
            else
                app.ScatterPanel.Visible = 'off';
            end
        end

        % Image clicked function: DistToDetectorLine
        function DistToDetectorLineImageClicked(app, ~)
            if strcmp(app.DistToDetectorUnits.Visible, 'off')
                app.DistToDetectorUnits.Visible = "on";
                app.DistToDetectorField.Visible = "on";
                app.DistToDetectorLabel.Visible = "on";
            else
                app.DistToDetectorUnits.Visible = "off";
                app.DistToDetectorField.Visible = "off";
                app.DistToDetectorLabel.Visible = "off";
            end

        end

        % Image clicked function: RotationImage
        function RotationImageClicked(app, ~)
            if strcmp(app.NumberofRotationsEditField.Visible, 'off')
                app.NumberofRotationsEditField.Visible = 'on';
                app.NumberofRotationsLabel.Visible = 'on';
            else
                app.NumberofRotationsEditField.Visible = 'off';
                app.NumberofRotationsLabel.Visible = 'off';
            end
        end

        % Callback function: RunButton, RunInContextMenu, RunMenu, 
        % ...and 1 other component
        function RunButtonPushed(app, event)
             % Run the simulation
             % Get the file path for locating examples
            pathToMLAPP = fileparts(mfilename('fullpath'));
            runningdlg = uiprogressdlg(app.UIFigure, 'Title', 'Running Simulation', 'Indeterminate', 'on');
            drawnow;
            try
                % Get the source
                source1_idx = app.Source1DropDown.ValueIndex;
                if source1_idx <= 2
                    source1 = load(fullfile(pathToMLAPP, ...
                        app.source_files{source1_idx}), 'source').source;
                else
                    source1 = app.Source1DropDown.ItemsData{source1_idx};
                end

                source2_idx = app.Source2DropDown.ValueIndex;
                has_source2 = source2_idx > 1;
                if has_source2
                    if source2_idx <= 3
                        source2 = load(fullfile(pathToMLAPP, ...
                            app.source_files{source2_idx-1}), 'source').source;
                    else
                        source2 = app.Source2DropDown.ItemsData{source2_idx};
                    end
                end

                % Get the phantom
                phantom_idx = app.PhantomListBox.ValueIndex;
                if phantom_idx <= 4
                    phantom = load(fullfile(pathToMLAPP, ...
                        app.phantom_files{phantom_idx}), 'phantom').phantom;
                else % phantom_idx > 4
                    index = app.PhantomListBox.ValueIndex;
                    phantom = app.PhantomListBox.ItemsData{index};
                end
                voxel_size = app.VoxelSizeEditField.Value;
                voxel_unit = units.(app.VoxelSizeUnits.Value);
                
                phantom = phantom.update_voxel_size(voxel_size * voxel_unit);

                % Get the detector
                detector_type = app.DetectorShapeDropDown.Value;           
                num_rotations = app.NumberofRotationsEditField.Value;

                dist_to_detector = app.DistToDetectorField.Value * ...
                    units.(app.DistToDetectorUnits.Value);
                
                % Get the pixel information
                pixel_size = app.PixelWidthField.Value * units.(app.PixelWidthUnits.Value);
                
                pixel_dims = [pixel_size pixel_size];
                num_pixels = [app.NumberofPixelsEditField.Value, 1];
                
                source_type = app.SourceTypeDropDown.Value;
                if strcmp(source_type, 'Parallel Beam')
                    g = parallel_gantry(dist_to_detector, num_rotations);
                    do_fan2para = false;
                else
                    g = gantry(dist_to_detector, num_rotations); % Should be cone beam
                    do_fan2para = true;
                end
                scan_angles = rad2deg(g.scan_angles);

                if strcmp(detector_type, 'Flat')
                    darray = flat_detector(pixel_dims, num_pixels);
                    sensor_geom = 'line';
                    sensor_spacing = 1 / 2;
                else
                    darray = curved_detector(pixel_dims, num_pixels);
                    sensor_geom = 'arc';
                    sensor_spacing = chord2ang(pixel_size, dist_to_detector);
                end
                
                [emin, emax] = source1.get_nrj_range();
                num_bins = ceil(emax - emin);
                sensor = ideal_sensor([emin, emax], num_bins);
                
                d = detector(g, darray, sensor);

                % Get the scatter settings
                scatter_type = lower(app.ScatterTypeListBox.Value);
                scatter_factor = app.ScatterFactorSpinner.Value;

                % Get the reconstruction information
                filter = app.FilterListBox.Value;
                interpolation = app.InterpolationDropDown.Value;

                % Source 1
                sinogram = squeeze(compute_sinogram(source1, phantom, d, scatter_type, scatter_factor));       
                if do_fan2para
                    rotation_angle = scan_angles(1); % Assumes even spacing 
                    [P,~,paraRotAngles] = fan2para(sinogram, (dist_to_detector/2)/pixel_dims(1), ...
                        'FanSensorSpacing', sensor_spacing, "Interpolation", interpolation, ...
                        'FanRotationIncrement', rotation_angle, ...
                        "FanSensorGeometry", sensor_geom ... 
                        , "ParallelCoverage", "cycle");
                    recon = iradon(P, paraRotAngles, interpolation, filter);
                else
                    recon = iradon(sinogram, scan_angles, interpolation, filter);
                end
                app.ShowDropDown.ItemsData{1} = gui.greyToColour(mat2gray(sinogram));
                app.recons{1} = gui.greyToColour(mat2gray(recon));

                % Source 2
                if has_source2
                    [emin, emax] = source2.get_nrj_range();
                    num_bins = ceil(emax - emin);
                    sensor2 = ideal_sensor([emin, emax], num_bins);
                    d2 = detector(g, darray, sensor2);
                    sinogram2 = squeeze(compute_sinogram(source2, phantom, d2, scatter_type, scatter_factor));
                    
                    % Reconstruct the image
                    % recon2 = iradon(sinogram2, scan_angles, interpolation, filter);
                    if do_fan2para
                        [P,~,paraRotAngles] = fan2para(sinogram2, (dist_to_detector/2)/pixel_dims(1), ...
                            'FanSensorSpacing', sensor_spacing, "Interpolation", interpolation, ...
                            'FanRotationIncrement', rotation_angle, ...
                            "FanSensorGeometry", sensor_geom ...
                            );%, "ParallelCoverage", "cycle");
                        recon2 = iradon(P, paraRotAngles, interpolation, filter);
                    else
                        recon2 = iradon(sinogram2, scan_angles, interpolation, filter);
                    end

                    app.ShowDropDown.ItemsData{2} = gui.greyToColour(mat2gray(sinogram2));
                    app.ShowDropDown.ItemsData{3} = gui.greyToColour(mat2gray(sinogram - sinogram2));
                    app.ShowDropDown.ItemsData{4} = gui.greyToColour(mat2gray(sinogram ./ sinogram2));
                    app.recons{2} = gui.greyToColour(mat2gray(recon2));
                    app.recons{3} = gui.greyToColour(mat2gray(recon2 - recon));
                    app.recons{4} = gui.greyToColour(mat2gray(recon2 ./ recon));
                else
                    app.ShowDropDown.ItemsData{4} = [];
                    app.ShowDropDown.ItemsData{3} = [];
                    app.ShowDropDown.ItemsData{2} = [];

                    app.recons{2} = [];
                    app.recons{3} = [];
                    app.recons{4} = [];
                end
                
                % Set the image from the sinogram and reconstruction
                app.ShowDropDownChanged(event); 
            catch ME
                uialert(app.UIFigure, getReport(ME,'extended','hyperlinks','off'), 'Error Running Simulation'); 
            end

            % Display the result
            runningdlg.close();
        end

        % Image clicked function: ReconstructionImage
        function ReconstructionImageClicked(app, event)
            type = get(gcbf, 'SelectionType');
            if strcmp(type, 'open')
                % Handle double-click action here
                app.ReconOpeninNewWindowMenuSelected(event)
            end
        end

        % Menu selected function: ReconstructionMenu
        function ReconSaveImageSelected(app, ~)
            if isempty(app.recons{1})
                errordlg('No file to save', 'Invalid file');
                return
            end 
            [file,path] = uiputfile(...
                {'*.png;*.jpeg','Image files'}, ...
                "Save Reconstructed Image");
            if ~ischar(file); return; end % Nothing selected
            imwrite(app.recons{app.ShowDropDown.ValueIndex}, fullfile(path, file), "png") % Could use event.ContextObject.ImageSource
        end

        % Menu selected function: SinogramMenu
        function SinogramSaveImageSelected(app, ~)
            if isempty(app.recons{1})
                errordlg('No file to save', 'Invalid file');
                return
            end 
            [file,path] = uiputfile(...
                {'*.png;*.jpeg','Image files'}, ...
                "Save Sinogram");
            if ~ischar(file); return; end % Nothing selected
            imwrite(app.ShowDropDown.ItemsData{app.ShowDropDown.ValueIndex},...
                fullfile(path, file), "png")
        end

        % Menu selected function: ReconstructionMenu_2
        function ReconOpeninNewWindowMenuSelected(app, ~)
            if isempty(app.recons{1}) % Check if reconstruction available
                errordlg('No reconstruction to view', 'Invalid Reconstruction');return;
            end
            fig_open = ~ishandle(app.recon_fig);
            if isempty(fig_open) || fig_open
                app.recon_fig = figure("Name","Reconstucted Image");
                imshow(app.recons{app.ShowDropDown.ValueIndex});
            else
                figure(app.recon_fig);
            end
        end

        % Menu selected function: SinogramMenu_2
        function SinogramOpeninNewWindowMenuSelected(app, ~)
            if isempty(app.recons{1}) % Check if reconstruction available (I will always create a reconstruction with a sinogram)
                errordlg('No sinogram to view', 'Invalid Sinogram');return;
            end

            fig_open = ~ishandle(app.sinogram_fig);
            if isempty(fig_open) || fig_open
                app.sinogram_fig = figure("Name","Sinogram");
                imshow(app.ShowDropDown.ItemsData{app.ShowDropDown.ValueIndex});
            else
                figure(app.sinogram_fig);
            end
        end

        % Value changed function: SourceTypeDropDown
        function SourceTypeDropDownValueChanged(app, ~)
            source_type = app.SourceTypeDropDown.Value;
            pathToMLAPP = fileparts(mfilename('fullpath'));
            if strcmp(source_type, 'Parallel Beam')
                app.RaysImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'parallel_rays.svg');
            else
                app.RaysImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'curved_rays.svg');
            end
        end

        % Value changed function: DetectorShapeDropDown
        function DetectorShapeDropDownValueChanged(app, ~)
            detector_type = app.DetectorShapeDropDown.Value;
            pathToMLAPP = fileparts(mfilename('fullpath'));
            if strcmp(detector_type, 'Flat')
                app.DetectorArrayImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'flat_detector.svg');
            else
                app.DetectorArrayImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'curved_detector.svg');
            end
        end

        % Callback function: LoadPhantomMenu, PhantomLoadButton
        function PhantomLoadButtonPushed(app, ~)
            [file,path] = uigetfile('*.mat','Load Saved Phantom File');
            if ischar(file)
                [~, name, ~] = fileparts(file);
                app.PhantomListBox.Items{end + 1} = name;
                try
                    app.PhantomListBox.ItemsData{end + 1} = ...
                        load(fullfile(path, file), 'phantom').phantom;
                    app.phantom_files{end+1} = fullfile(path, file);
                catch ME
                    % If there is an error loading the phantom - let the user know
                    uialert(app.UIFigure, ME.message, 'Invalid Phantom File');
                end
            end
        end

        % Callback function: LoadSourceMenu, SourceLoadButton
        function SourceLoadButtonPushed(app, ~)
            [file,path] = uigetfile({'*.mat;*.spk', 'MATLAB file or SpekPy spectrum file (*.mat, *.spk)'}, 'Load Saved Source File');
            if ischar(file)
                [~, name, ext] = fileparts(file);
                app.Source1DropDown.Items{end+1} = name;
                app.Source2DropDown.Items{end+1} = name;
                try
                    if ext == ".spk"
                        loaded_source = source_fromfile(fullfile(path, file));
                    else
                        loaded_source = load(fullfile(path, file), 'source').source;
                    end
                catch ME
                    % If there is an error loading the source - let the user know
                    uialert(app.UIFigure, ME.message, 'Invalid Source File');
                end
                app.Source1DropDown.ItemsData{end+1} = loaded_source;
                app.Source2DropDown.ItemsData{end+1} = loaded_source;
            end % Nothing selected
        end

        % Menu selected function: ResetInContextMenu, ResetMenu
        function ResetMenuSelected(app, ~)
            % Reset the app to its initial state

            % Check if the user wants to reset
            choice = uiconfirm(app.UIFigure,'Reset the app?', ...
                'Confirm Reset', ...
                "Icon","warning");
            if ~strcmp(choice, 'OK'); return; end
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Set all the panels to invisible
            app.ReconstructionPanel.Visible = 'off';
            app.DetectorPanel.Visible = 'off';
            app.PhantomPanel.Visible = 'off';
            app.SourcePanel.Visible = 'off';
            app.ScatterPanel.Visible = 'off';

            % Reset the images
            app.RaysImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'parallel_rays.svg');
            app.DetectorArrayImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'flat_detector.svg');
            
            app.ShowDropDown.ItemsData = {'Source 1'};
            app.recons = {[]};
            
            % app.SinogramImage.ImageSource = fullfile(pathToMLAPP, 'Initial Image.png');
            clf(app.UIAxes);
            app.ReconstructionImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'Initial Image.png');
            
            % Reset the dropdowns
            app.Source1DropDown.Items = {'Low Energy (40 kvp)', 'High Energy (80 kvp)'};
            app.Source1DropDown.ItemsData = {'Low Energy (40 kvp)', 'High Energy (80 kvp)'};
            app.Source1DropDown.Value = 'Low Energy (40 kvp)';
            app.Source2DropDown.Items = {'None', 'Low Energy (40 kvp)', 'High Energy (80 kvp)'};
            app.Source2DropDown.ItemsData = {'None', 'Low Energy (40 kvp)', 'High Energy (80 kvp)'};
            app.Source2DropDown.Value = 'None';
            app.PhantomListBox.Items = {'Example 1', 'Example 2'};
            app.PhantomListBox.ItemsData = {'Example 1', 'Example 2'};

            % Reset the edit fields
            app.VoxelSizeEditField.Value = 1;
            app.PixelWidthField.Value = 1;
            app.NumberofPixelsEditField.Value = 900;
            app.DistToDetectorField.Value = 100;
            app.NumberofRotationsEditField.Value = 180;
            app.FilterListBox.Value = 'None';
            app.InterpolationDropDown.Value = 'linear';
            app.SensorTypeDropDown.Value = 'Ideal';
            app.PixelWidthUnits.Value = 'mm';
            app.VoxelSizeUnits.Value = 'mm';
            app.DistToDetectorUnits.Value = 'cm';
            app.SourceTypeDropDown.Value = 'Parallel Beam';
            app.DetectorShapeDropDown.Value = 'Flat';
            app.ScatterTypeListBox.Value = 'None';
            app.ScatterFactorSpinner.Value = 0;
        end

        % Value changed function: ShowDropDown
        function ShowDropDownChanged(app, ~)
            idx = app.ShowDropDown.ValueIndex;
            if ~isempty(app.recons{1})
                if idx > 1 && isempty(app.recons{2})
                    uialert(app.UIFigure, 'No second source to compare', 'No second source');
                    app.ShowDropDown.Value = app.ShowDropDown.ItemsData{1};
                else
                    app.ReconstructionImage.ImageSource = app.recons{idx};
                    num_pixels = size(app.ShowDropDown.ItemsData{idx}, 1);
                    
                    imagesc(app.UIAxes, [0 360], [0 num_pixels], app.ShowDropDown.ItemsData{idx});
                    app.UIAxes.YLim = [0, num_pixels];
                    app.UIAxes.YTick = [0, num_pixels/2, num_pixels];
                    % Scale the x-axis, so that the rotation number is correct to the angle
                    % num_rotations = app.NumberofRotationsEditField.Value;
                end
            else
                uialert(app.UIFigure, 'No images have been created, run the program first', 'No Images');
                app.ShowDropDown.Value = app.ShowDropDown.ItemsData{1};
            end
        end

        % Value changed function: DistToDetectorUnits, PixelWidthUnits, 
        % ...and 1 other component
        function UnitsValueChanged(app, event)
            value = event.Value;
            if ~(strcmp(value, "m") || strcmp(value, "cm") || strcmp(value, "mm") || strcmp(value, "um") || strcmp(value, "nm"))
                uialert(app.UIFigure, 'Invalid unit selection', 'Invalid units');
                event.Source.Value = event.Source.Items{2};
            end
        end

        % Menu selected function: SaveStateInContextMenu, SaveStateMenu
        function SaveStateSelected(app, ~)
            [file,path] = uiputfile('*.mat','Save State');
            if ~ischar(file); return; end % Nothing selected
            state.recon_visible    = app.ReconstructionPanel.Visible;
            state.detector_visible = app.DetectorPanel.Visible;
            state.phantom_visible  = app.PhantomPanel.Visible;
            state.source_visible   = app.SourcePanel.Visible;
            state.scatter_visible  = app.ScatterPanel.Visible;
            
            % Get the source information
            state.source1_selected = app.Source1DropDown.Value;
            state.source2_selected = app.Source2DropDown.Value;
            state.source1s         = app.Source1DropDown.Items;
            state.source2s         = app.Source2DropDown.Items;
            state.source_data1     = app.Source1DropDown.ItemsData;
            state.source_data2     = app.Source2DropDown.ItemsData;
            state.source_type      = app.SourceTypeDropDown.Value;

            % Get the detector information
            state.detector_shape   = app.DetectorShapeDropDown.Value;
            state.num_pixels       = app.NumberofPixelsEditField.Value;
            state.pixel_width      = app.PixelWidthField.Value;
            state.pixel_units      = app.PixelWidthUnits.Value;
            state.sensor_type      = app.SensorTypeDropDown.Value;

            % Get the phantom information
            state.phantom_selected = app.PhantomListBox.Value;
            state.phantoms         = app.PhantomListBox.Items;
            state.phantom_data     = app.PhantomListBox.ItemsData;
            state.voxel_size       = app.VoxelSizeEditField.Value;
            state.voxel_units      = app.VoxelSizeUnits.Value;

            % Get the gantry information
            state.dist_to_detector = app.DistToDetectorField.Value;
            state.dist_units       = app.DistToDetectorUnits.Value;
            state.num_rotations    = app.NumberofRotationsEditField.Value;

            % Get the scatter and reconstruction information
            state.filter           = app.FilterListBox.Value;
            state.interpolation    = app.InterpolationDropDown.Value;
            state.scatter_type     = app.ScatterTypeListBox.Value;
            state.scatter_factor   = app.ScatterFactorSpinner.Value;

            state.show             = app.ShowDropDown.Value;
            state.show_data        = app.ShowDropDown.ItemsData;
            state.recons           = app.recons;
            
            state.recon_fig        = app.recon_fig;
            state.sinogram_fig     = app.sinogram_fig;
            save(fullfile(path, file), 'state');
        end

        % Menu selected function: LoadStateInContextMenu, LoadStateMenu
        function LoadStateSelected(app, event)
            try
                state_file = uigetfile('*.mat','Load State');
                state = load(state_file, 'state').state;
            catch ME
                uialert(app.UIFigure, ME.message, 'Invalid State File');
            end
            if ~ischar(state_file); return; end % Nothing selected
            app.ReconstructionPanel.Visible = state.recon_visible;
            app.DetectorPanel.Visible = state.detector_visible;
            app.PhantomPanel.Visible = state.phantom_visible;
            app.SourcePanel.Visible = state.source_visible;
            app.ScatterPanel.Visible = state.scatter_visible;

            % Set the source information
            app.Source1DropDown.ItemsData = state.source_data1;
            app.Source2DropDown.ItemsData = state.source_data2;
            app.Source1DropDown.Items = state.source1s;
            app.Source2DropDown.Items = state.source2s;
            app.Source1DropDown.Value = state.source1_selected;
            app.Source2DropDown.Value = state.source2_selected;
            app.SourceTypeDropDown.Value = state.source_type;

            % Set the detector information
            app.DetectorShapeDropDown.Value = state.detector_shape;
            app.NumberofPixelsEditField.Value = state.num_pixels;
            app.PixelWidthField.Value = state.pixel_width;
            app.PixelWidthUnits.Value = state.pixel_units;
            app.SensorTypeDropDown.Value = state.sensor_type;

            % Set the phantom information
            app.PhantomListBox.ItemsData = state.phantom_data;
            app.PhantomListBox.Items = state.phantoms;
            app.PhantomListBox.Value = state.phantom_selected;            
            app.VoxelSizeEditField.Value = state.voxel_size;
            app.VoxelSizeUnits.Value = state.voxel_units;

            % Set the gantry information
            app.DistToDetectorField.Value = state.dist_to_detector;
            app.DistToDetectorUnits.Value = state.dist_units;
            app.NumberofRotationsEditField.Value = state.num_rotations;

            % Set the scatter and reconstruction information
            app.FilterListBox.Value = state.filter;
            app.InterpolationDropDown.Value = state.interpolation;
            app.ScatterTypeListBox.Value = state.scatter_type;
            app.ScatterFactorSpinner.Value = state.scatter_factor;

            app.ShowDropDown.ItemsData = state.show_data;
            app.ShowDropDown.Value = state.show;
            app.recons = state.recons;
            
            app.recon_fig = state.recon_fig;
            app.sinogram_fig = state.sinogram_fig;
            
            app.ShowDropDownChanged(event);
            app.DetectorShapeDropDownValueChanged(event);
            app.SourceTypeDropDownValueChanged(event);
        end

        % Menu selected function: ReconstructionHelpMenu
        function ReconstructionHelpMenuSelected(~, ~)
            doc iradon
            web('docs/build/html/user_guide/gui.html#reconstruction')
        end

        % Menu selected function: ExportMenu, ExporttoScriptMenu
        function ExporttoScriptMenuSelected(app, ~)
            % Create a script to run the simulation
            [file,path] = uiputfile('*.m','Save Script');
            if ~ischar(file); return; end % Nothing selected
            fid = fopen(fullfile(path, file), 'w');

            pathToMLAPP = fileparts(mfilename('fullpath'));
            
            fprintf(fid, "%% Run the simulation\n");
            fprintf(fid, "\n%% Get the source\n");
            source1_selected = app.Source1DropDown.ValueIndex;
            if source1_selected <= 2
                fprintf(fid, "source1 = load('%s', 'source').source;\n", ...
                    fullfile(pathToMLAPP, app.source_files{source1_selected}));
            else
                source1 = app.Source1DropDown.ItemsData{source1_selected};
                save(fullfile(path, 'source1.mat'), "source1");
                fprintf(fid, "source1 = load('%s', 'source1').source1;\n", ...
                    fullfile(path, 'source1.mat'));
            end

            source2_selected = app.Source2DropDown.ValueIndex;
            has_source2 = source2_selected > 1;
            if has_source2 && source2_selected <= 3
                fprintf(fid, "source2 = load('%s', 'source').source;\n", ...
                    fullfile(pathToMLAPP, app.source_files{source2_selected}));
            elseif source2_selected > 3
                source2 = app.Source2DropDown.ItemsData{source2_selected};
                save(fullfile(path, 'source2.mat'), "source2");
                fprintf(fid, "source2 = load('%s', 'source2').source2;\n", ...
                    fullfile(path, 'source2.mat'));
            end

            % Get the phantom
            phantom_selected = app.PhantomListBox.ValueIndex;
            fprintf(fid, "\n%% Get the phantom\n");
            if phantom_selected <= 4
                fprintf(fid, "phantom = load('%s', 'phantom').phantom;\n", ...
                    fullfile(pathToMLAPP, app.phantom_files{phantom_selected}));
            else % phantom_selected > 2
                fprintf(fid, "phantom = load('%s', 'phantom').phantom;\n", ...
                    app.phantom_files{phantom_selected});
            end
            fprintf(fid, "phantom = phantom.update_voxel_size(%f * units.%s);\n", ...
                app.VoxelSizeEditField.Value, app.VoxelSizeUnits.Value);
            
            % Get the detector
            fprintf(fid, "\n%% Get the detector movement\n");
            detector_type = app.DetectorShapeDropDown.Value;
            num_rotations = app.NumberofRotationsEditField.Value;
            fprintf(fid, "num_rotations = %d;\n", num_rotations);

            dist_to_detector = app.DistToDetectorField.Value;
            fprintf(fid, "dist_to_detector = %f * units.%s;\n", ...
                dist_to_detector, app.DistToDetectorUnits.Value);
            

            source_type = app.SourceTypeDropDown.Value;
            if strcmp(source_type, 'Parallel Beam')
                fprintf(fid, "the_gantry = parallel_gantry(dist_to_detector, num_rotations);\n");
            else
                fprintf(fid, "the_gantry = gantry(dist_to_detector, num_rotations);\n");
            end

            fprintf(fid, "\n%% Get the detector pixel configuration (i.e. detector array)\n");
            pixel_size = app.PixelWidthField.Value;
            fprintf(fid, "pixel_dims = [%f %f] .* units.%s;\n", ...
                pixel_size, pixel_size, app.PixelWidthUnits.Value);
            num_pixels = app.NumberofPixelsEditField.Value;
            fprintf(fid, "num_pixels = [%d, 1];\n", num_pixels);
            if strcmp(detector_type, 'Flat')
                fprintf(fid, "darray = flat_detector(pixel_dims, num_pixels);\n");
                fprintf(fid, "sensor_geom = 'line';\n");
                fprintf(fid, "sensor_spacing = pixel_dims(1) / 2;\n");
            else
                fprintf(fid, "darray = curved_detector(pixel_dims, num_pixels);\n");
                fprintf(fid, "sensor_geom = 'arc';\n");
                fprintf(fid, "sensor_spacing = chord2ang(pixel_dims(1), dist_to_detector);\n");
            end

            fprintf(fid, "\n%% Get the sensor on the detector\n");
            fprintf(fid, "[emin, emax] = source1.get_nrj_range();\n");
            fprintf(fid, "num_bins = ceil(emax - emin);\n");
            fprintf(fid, "sensor = ideal_sensor([emin, emax], num_bins);\n");

            fprintf(fid, "\n%% Build the detector\n");
            fprintf(fid, "d = detector(the_gantry, darray, sensor);\n");
            
            % Get the scatter settings
            fprintf(fid, "\n%% Get the scatter settings\n");
            scatter_type = lower(app.ScatterTypeListBox.Value);
            scatter_factor = app.ScatterFactorSpinner.Value;
            fprintf(fid, "scatter_type = '%s';\n", scatter_type);
            fprintf(fid, "scatter_factor = %d;\n", scatter_factor);

            % Get the reconstruction information
            filter = app.FilterListBox.Value;
            interpolation = app.InterpolationDropDown.Value;
            fprintf(fid, "\n%% Compute the sinogram for source 1\n");
            fprintf(fid, "sinogram = squeeze(compute_sinogram(source1, phantom, d, scatter_type, scatter_factor));\n");

            if has_source2
                fprintf(fid, "\n%% Compute the sinogram for source 2\n");
                fprintf(fid, "[emin, emax] = source2.get_nrj_range();\n");
                fprintf(fid, "num_bins = ceil(emax - emin);\n");
                fprintf(fid, "sensor2 = ideal_sensor([emin, emax], num_bins);\n");
                fprintf(fid, "d2 = detector(the_gantry, darray, sensor2);\n");
                fprintf(fid, "sinogram2 = squeeze(compute_sinogram(source2, phantom, d2, scatter_type, scatter_factor));\n");
            end

            fprintf(fid, "\n%% Get the reconstruction information\n");
            fprintf(fid, "filter = '%s';\n", filter);
            fprintf(fid, "interpolation = '%s';\n", interpolation);
            fprintf(fid, "scan_angles = rad2deg(the_gantry.scan_angles);\n");
            fprintf(fid, "\n%% Reconstruct the image for source 1\n");
            if strcmp(source_type, 'Parallel Beam')
                fprintf(fid, "recon = iradon(sinogram, scan_angles, interpolation, filter);\n");
            else
                fprintf(fid, "radius = dist_to_detector/2;\n");
                fprintf(fid, "[P,~,paraRotAngles] = fan2para(sinogram, radius/pixel_dims(1), ...\n");
                fprintf(fid, "    'FanSensorSpacing', sensor_spacing, ...\n");
                fprintf(fid, "    'Interpolation', interpolation, ...\n");
                fprintf(fid, "    'FanRotationIncrement', 2*pi / num_rotations, ...\n");
                fprintf(fid, "    'FanSensorGeometry', sensor_geom ...\n");
                fprintf(fid, "    );\n");
                fprintf(fid, "recon = iradon(P, paraRotAngles, interpolation, filter);\n");
            end

            if has_source2
                fprintf(fid, "\n%% Reconstruct the image for source 2\n");
                if strcmp(source_type, 'Parallel Beam')
                    fprintf(fid, "recon2 = iradon(sinogram2, scan_angles, interpolation, filter);\n");
                else
                    fprintf(fid, "[P,~,paraRotAngles] = fan2para(sinogram2, radius/pixel_dims(1), ...\n");
                    fprintf(fid, "    'FanSensorSpacing', sensor_spacing, ...\n");
                    fprintf(fid, "    'Interpolation', interpolation, ...\n");
                    fprintf(fid, "    'FanRotationIncrement', 2*pi / num_rotations, ...\n");
                    fprintf(fid, "    'FanSensorGeometry', sensor_geom ...\n");
                    fprintf(fid, "    );\n");
                    fprintf(fid, "recon2 = iradon(P, paraRotAngles, interpolation, filter);\n");
                end
            end
            
            fprintf(fid, "\n%% Display the result\n");
            fprintf(fid, "figure; imshow(mat2gray(recon));\n");
            if has_source2
                fprintf(fid, "figure; imshow(mat2gray(recon2));\n");
            end
            fclose(fid);
        end

        % Menu selected function: DocumentationMenu
        function DocumentationMenuSelected(~, ~)
            web('docs\build\html\index.html')
        end

        % Menu selected function: SourceHelpMenu_run
        function SourceHelpMenu_runSelected(~, ~)
            web('docs/build/html/user_guide/gui.html#source')
        end

        % Menu selected function: PhantomHelpMenu_run
        function PhantomHelpMenu_runSelected(~, ~)
            web('docs/build/html/user_guide/gui.html#phantom')
        end

        % Menu selected function: DetectorHelpMenu_run
        function DetectorContextMenuSelected(~, ~)
            web('docs/build/html/user_guide/gui.html#detector')
        end

        % Menu selected function: ScatterHelpMenu
        function ScatterContextMenuSelected(~, ~)
            web('docs/build/html/user_guide/gui.html#scatter')
        end

        % Menu selected function: ReconstructionMenu_3, SinogramMenu_3
        function OpeninImageViewerMenuSelected(app, event)
            show_sinogram = strcmp(event.Source.Text, 'Sinogram');
            if isempty(app.recons{1})
                errordlg('No sinogram to view', 'Invalid Sinogram');return;
            end
            try
                if show_sinogram
                    imageViewer(app.ShowDropDown.ItemsData{app.ShowDropDown.ValueIndex});
                else
                    imageViewer(app.recons{app.ShowDropDown.ValueIndex})
                end
            catch ME
                % If there is an error opening the image viewer - tell the user the error and suggest they install the image processing toolbox
                message = sprintf('Error opening the image viewer: %s\nIt is possible that the image processing toolbox is not installed. You can install it from the Add-Ons menu.', ME.message);
                uialert(app.UIFigure, message, 'Error opening image viewer');
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1366 768];
            app.UIFigure.Name = 'DECTSim App';
            app.UIFigure.Icon = fullfile(pathToMLAPP, 'graphics', 'scatter_rays.svg');
            app.UIFigure.Resize = 'off';

            % Create FileMenu
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.Text = 'File';

            % Create RunMenu
            app.RunMenu = uimenu(app.FileMenu);
            app.RunMenu.MenuSelectedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunMenu.Text = 'Run';

            % Create LoadStateMenu
            app.LoadStateMenu = uimenu(app.FileMenu);
            app.LoadStateMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadStateSelected, true);
            app.LoadStateMenu.Text = 'Load State';

            % Create SaveStateMenu
            app.SaveStateMenu = uimenu(app.FileMenu);
            app.SaveStateMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveStateSelected, true);
            app.SaveStateMenu.Text = 'Save State';

            % Create ExportMenu
            app.ExportMenu = uimenu(app.FileMenu);
            app.ExportMenu.MenuSelectedFcn = createCallbackFcn(app, @ExporttoScriptMenuSelected, true);
            app.ExportMenu.Text = 'Export to Script';

            % Create ResetMenu
            app.ResetMenu = uimenu(app.FileMenu);
            app.ResetMenu.MenuSelectedFcn = createCallbackFcn(app, @ResetMenuSelected, true);
            app.ResetMenu.Text = 'Reset';

            % Create HelpMenu
            app.HelpMenu = uimenu(app.UIFigure);
            app.HelpMenu.Text = 'Help';

            % Create DocumentationMenu
            app.DocumentationMenu = uimenu(app.HelpMenu);
            app.DocumentationMenu.MenuSelectedFcn = createCallbackFcn(app, @DocumentationMenuSelected, true);
            app.DocumentationMenu.Text = 'Documentation';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.TabLocation = 'bottom';
            app.TabGroup.Position = [1 1 1366 768];

            % Create RunTab
            app.RunTab = uitab(app.TabGroup);
            app.RunTab.Title = 'Run';

            % Create ReconstructionPanel
            app.ReconstructionPanel = uipanel(app.RunTab);
            app.ReconstructionPanel.Title = 'Reconstruction';
            app.ReconstructionPanel.Visible = 'off';
            app.ReconstructionPanel.FontSize = 18;
            app.ReconstructionPanel.Position = [582 4 276 185];

            % Create FilterListBoxLabel
            app.FilterListBoxLabel = uilabel(app.ReconstructionPanel);
            app.FilterListBoxLabel.HorizontalAlignment = 'right';
            app.FilterListBoxLabel.FontSize = 14;
            app.FilterListBoxLabel.Position = [44 120 36 22];
            app.FilterListBoxLabel.Text = 'Filter';

            % Create FilterListBox
            app.FilterListBox = uilistbox(app.ReconstructionPanel);
            app.FilterListBox.Items = {'None', 'Ram-Lak', 'Shepp-Logan', 'Cosine', 'Hamming', 'Hann'};
            app.FilterListBox.Tooltip = {'Filter to use for frequency domain filtering, specified as one of these values.'};
            app.FilterListBox.FontSize = 14;
            app.FilterListBox.Position = [95 78 126 66];
            app.FilterListBox.Value = 'None';

            % Create InterpolationDropDownLabel
            app.InterpolationDropDownLabel = uilabel(app.ReconstructionPanel);
            app.InterpolationDropDownLabel.HorizontalAlignment = 'right';
            app.InterpolationDropDownLabel.FontSize = 14;
            app.InterpolationDropDownLabel.Position = [30 33 82 22];
            app.InterpolationDropDownLabel.Text = 'Interpolation';

            % Create InterpolationDropDown
            app.InterpolationDropDown = uidropdown(app.ReconstructionPanel);
            app.InterpolationDropDown.Items = {'nearest', 'linear', 'spline', 'pchip'};
            app.InterpolationDropDown.Tooltip = {'Type of interpolation to use in the back projection, specified as one of these values. The values are listed in order of increasing accuracy and computational complexity.'};
            app.InterpolationDropDown.FontSize = 14;
            app.InterpolationDropDown.Position = [127 33 100 22];
            app.InterpolationDropDown.Value = 'linear';

            % Create ResultsPanel
            app.ResultsPanel = uipanel(app.RunTab);
            app.ResultsPanel.FontSize = 18;
            app.ResultsPanel.Position = [858 1 508 744];

            % Create UIAxes
            app.UIAxes = uiaxes(app.ResultsPanel);
            title(app.UIAxes, 'Sinogram')
            xlabel(app.UIAxes, 'Angle')
            ylabel(app.UIAxes, 'Pixel')
            app.UIAxes.LabelFontSizeMultiplier = 1;
            app.UIAxes.XLim = [0 360];
            app.UIAxes.YLim = [0 900];
            app.UIAxes.XLimitMethod = 'tight';
            app.UIAxes.YLimitMethod = 'tight';
            app.UIAxes.XTick = [0 60 120 180 240 300 360];
            app.UIAxes.YTick = [0 450 900];
            app.UIAxes.ZTick = [];
            app.UIAxes.Color = 'none';
            app.UIAxes.TitleHorizontalAlignment = 'left';
            app.UIAxes.TickDir = 'in';
            app.UIAxes.FontSize = 14;
            app.UIAxes.TitleFontSizeMultiplier = 1;
            app.UIAxes.Position = [4 4 499 290];

            % Create ReconstructionImage
            app.ReconstructionImage = uiimage(app.ResultsPanel);
            app.ReconstructionImage.ImageClickedFcn = createCallbackFcn(app, @ReconstructionImageClicked, true);
            app.ReconstructionImage.Tooltip = {'The reconstructed image from the sinogram. '; ''; 'Double-click to get in a MATLAB viewer.'};
            app.ReconstructionImage.Position = [4 294 499 424];
            app.ReconstructionImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'Initial Image.png');

            % Create Label
            app.Label = uilabel(app.ResultsPanel);
            app.Label.FontSize = 18;
            app.Label.Position = [212 287 25 23];
            app.Label.Text = '';

            % Create ReconstructedImageLabel
            app.ReconstructedImageLabel = uilabel(app.ResultsPanel);
            app.ReconstructedImageLabel.FontSize = 18;
            app.ReconstructedImageLabel.Position = [4 717 176 23];
            app.ReconstructedImageLabel.Text = 'Reconstructed Image';

            % Create ShowDropDownLabel
            app.ShowDropDownLabel = uilabel(app.ResultsPanel);
            app.ShowDropDownLabel.HorizontalAlignment = 'right';
            app.ShowDropDownLabel.FontSize = 14;
            app.ShowDropDownLabel.Position = [347 718 44 22];
            app.ShowDropDownLabel.Text = 'Show:';

            % Create ShowDropDown
            app.ShowDropDown = uidropdown(app.ResultsPanel);
            app.ShowDropDown.Items = {'Source 1', 'Source 2', 'Difference', 'Ratio'};
            app.ShowDropDown.ItemsData = {'Source 1'};
            app.ShowDropDown.ValueChangedFcn = createCallbackFcn(app, @ShowDropDownChanged, true);
            app.ShowDropDown.Tooltip = {'Select which combination of sinogram and reconstruction to view'};
            app.ShowDropDown.FontSize = 14;
            app.ShowDropDown.Position = [406 718 100 22];
            app.ShowDropDown.Value = 'Source 1';

            % Create DetectorPanel
            app.DetectorPanel = uipanel(app.RunTab);
            app.DetectorPanel.Title = 'Detector';
            app.DetectorPanel.Visible = 'off';
            app.DetectorPanel.FontSize = 18;
            app.DetectorPanel.Position = [581 202 277 193];

            % Create SensorTypeDropDownLabel
            app.SensorTypeDropDownLabel = uilabel(app.DetectorPanel);
            app.SensorTypeDropDownLabel.HorizontalAlignment = 'right';
            app.SensorTypeDropDownLabel.FontSize = 14;
            app.SensorTypeDropDownLabel.Position = [37 14 83 22];
            app.SensorTypeDropDownLabel.Text = 'Sensor Type';

            % Create SensorTypeDropDown
            app.SensorTypeDropDown = uidropdown(app.DetectorPanel);
            app.SensorTypeDropDown.Items = {'Ideal'};
            app.SensorTypeDropDown.Tooltip = {'This determines how your sensor reacts to exposure to X-rays'};
            app.SensorTypeDropDown.FontSize = 14;
            app.SensorTypeDropDown.Position = [140 14 110 22];
            app.SensorTypeDropDown.Value = 'Ideal';

            % Create PixelWidthLabel
            app.PixelWidthLabel = uilabel(app.DetectorPanel);
            app.PixelWidthLabel.HorizontalAlignment = 'center';
            app.PixelWidthLabel.FontSize = 14;
            app.PixelWidthLabel.Tooltip = {'This determines the size of each of the sensors (and therefore pixels) in the detector. '; ''; 'A smaller pixel width increases the resolution of the image.'};
            app.PixelWidthLabel.Position = [36 93 75 22];
            app.PixelWidthLabel.Text = 'Pixel Width';

            % Create PixelWidthField
            app.PixelWidthField = uieditfield(app.DetectorPanel, 'numeric');
            app.PixelWidthField.LowerLimitInclusive = 'off';
            app.PixelWidthField.Limits = [0 Inf];
            app.PixelWidthField.FontSize = 14;
            app.PixelWidthField.Tooltip = {'This determines the size of each of the sensors (and therefore pixels) in the detector. '; ''; 'A smaller pixel width increases the resolution of the image.'};
            app.PixelWidthField.Position = [138 91 46 22];
            app.PixelWidthField.Value = 1;

            % Create PixelWidthUnits
            app.PixelWidthUnits = uidropdown(app.DetectorPanel);
            app.PixelWidthUnits.Items = {'mm', 'um'};
            app.PixelWidthUnits.Editable = 'on';
            app.PixelWidthUnits.ValueChangedFcn = createCallbackFcn(app, @UnitsValueChanged, true);
            app.PixelWidthUnits.Tooltip = {'This determines the size of each of the sensors (and therefore pixels) in the detector. '; ''; 'A smaller pixel width increases the resolution of the image.'};
            app.PixelWidthUnits.FontSize = 14;
            app.PixelWidthUnits.BackgroundColor = [1 1 1];
            app.PixelWidthUnits.Position = [190 91 56 22];
            app.PixelWidthUnits.Value = 'mm';

            % Create NumberofPixelsEditFieldLabel
            app.NumberofPixelsEditFieldLabel = uilabel(app.DetectorPanel);
            app.NumberofPixelsEditFieldLabel.HorizontalAlignment = 'center';
            app.NumberofPixelsEditFieldLabel.FontSize = 14;
            app.NumberofPixelsEditFieldLabel.Position = [10 49 133 23];
            app.NumberofPixelsEditFieldLabel.Text = 'Number of Pixels';

            % Create NumberofPixelsEditField
            app.NumberofPixelsEditField = uieditfield(app.DetectorPanel, 'numeric');
            app.NumberofPixelsEditField.Limits = [1 Inf];
            app.NumberofPixelsEditField.RoundFractionalValues = 'on';
            app.NumberofPixelsEditField.FontSize = 14;
            app.NumberofPixelsEditField.Tooltip = {'This, along with the pixel size determines the size of the array of sensors. '; ''; 'More pixels means the detector with have greater breadth'};
            app.NumberofPixelsEditField.Position = [162 49 56 22];
            app.NumberofPixelsEditField.Value = 900;

            % Create DetectorShapeDropDownLabel
            app.DetectorShapeDropDownLabel = uilabel(app.DetectorPanel);
            app.DetectorShapeDropDownLabel.HorizontalAlignment = 'right';
            app.DetectorShapeDropDownLabel.FontSize = 14;
            app.DetectorShapeDropDownLabel.Position = [17 129 102 22];
            app.DetectorShapeDropDownLabel.Text = 'Detector Shape';

            % Create DetectorShapeDropDown
            app.DetectorShapeDropDown = uidropdown(app.DetectorPanel);
            app.DetectorShapeDropDown.Items = {'Flat', 'Cylindrical'};
            app.DetectorShapeDropDown.ValueChangedFcn = createCallbackFcn(app, @DetectorShapeDropDownValueChanged, true);
            app.DetectorShapeDropDown.Tooltip = {'This is the shape of the arrangement of sensors used to detect the X-rays.'};
            app.DetectorShapeDropDown.FontSize = 14;
            app.DetectorShapeDropDown.Position = [139 129 110 22];
            app.DetectorShapeDropDown.Value = 'Flat';

            % Create PhantomPanel
            app.PhantomPanel = uipanel(app.RunTab);
            app.PhantomPanel.Tooltip = {'A phantom is the irradiated object used in the simulation'};
            app.PhantomPanel.Title = 'Phantom';
            app.PhantomPanel.Visible = 'off';
            app.PhantomPanel.FontSize = 18;
            app.PhantomPanel.Position = [581 412 277 160];

            % Create PhantomListBoxLabel
            app.PhantomListBoxLabel = uilabel(app.PhantomPanel);
            app.PhantomListBoxLabel.HorizontalAlignment = 'right';
            app.PhantomListBoxLabel.FontSize = 14;
            app.PhantomListBoxLabel.Tooltip = {'A phantom is the irradiated object used in the simulation'};
            app.PhantomListBoxLabel.Position = [19 101 61 22];
            app.PhantomListBoxLabel.Text = 'Phantom';

            % Create PhantomListBox
            app.PhantomListBox = uilistbox(app.PhantomPanel);
            app.PhantomListBox.Items = {'Modified Shepp Logan', 'Example 2', 'Example 3', 'Example 4'};
            app.PhantomListBox.ItemsData = {'Modified Shepp Logan', 'Example 2', 'Example 3', 'Example 4'};
            app.PhantomListBox.Tooltip = {'Select the available phantoms'};
            app.PhantomListBox.Position = [95 51 158 74];
            app.PhantomListBox.Value = 'Modified Shepp Logan';

            % Create PhantomLoadButton
            app.PhantomLoadButton = uibutton(app.PhantomPanel, 'push');
            app.PhantomLoadButton.ButtonPushedFcn = createCallbackFcn(app, @PhantomLoadButtonPushed, true);
            app.PhantomLoadButton.FontSize = 14;
            app.PhantomLoadButton.Tooltip = {'Load a ''.mat'' file containing the variable ''phantom'', to run the simulation with.'};
            app.PhantomLoadButton.Position = [21 51 66 25];
            app.PhantomLoadButton.Text = 'Load';

            % Create VoxelSizeEditFieldLabel
            app.VoxelSizeEditFieldLabel = uilabel(app.PhantomPanel);
            app.VoxelSizeEditFieldLabel.HorizontalAlignment = 'right';
            app.VoxelSizeEditFieldLabel.FontSize = 14;
            app.VoxelSizeEditFieldLabel.Tooltip = {'This determines the resolution of your phantom. '; ''; 'A smaller voxel size increases accuracy, but increases execution time'};
            app.VoxelSizeEditFieldLabel.Position = [31 10 70 22];
            app.VoxelSizeEditFieldLabel.Text = 'Voxel Size';

            % Create VoxelSizeEditField
            app.VoxelSizeEditField = uieditfield(app.PhantomPanel, 'numeric');
            app.VoxelSizeEditField.LowerLimitInclusive = 'off';
            app.VoxelSizeEditField.Limits = [0 Inf];
            app.VoxelSizeEditField.FontSize = 14;
            app.VoxelSizeEditField.Tooltip = {'This determines the resolution of your phantom. '; ''; 'A smaller voxel size increases accuracy, but increases execution time'};
            app.VoxelSizeEditField.Position = [117 10 46 22];
            app.VoxelSizeEditField.Value = 1;

            % Create VoxelSizeUnits
            app.VoxelSizeUnits = uidropdown(app.PhantomPanel);
            app.VoxelSizeUnits.Items = {'cm', 'mm', 'um'};
            app.VoxelSizeUnits.Editable = 'on';
            app.VoxelSizeUnits.ValueChangedFcn = createCallbackFcn(app, @UnitsValueChanged, true);
            app.VoxelSizeUnits.Tooltip = {'This determines the resolution of your phantom. '; ''; 'A smaller voxel size increases accuracy, but increases execution time'};
            app.VoxelSizeUnits.FontSize = 14;
            app.VoxelSizeUnits.BackgroundColor = [1 1 1];
            app.VoxelSizeUnits.Position = [173 10 67 22];
            app.VoxelSizeUnits.Value = 'mm';

            % Create SourcePanel
            app.SourcePanel = uipanel(app.RunTab);
            app.SourcePanel.Title = 'Source';
            app.SourcePanel.Visible = 'off';
            app.SourcePanel.FontSize = 18;
            app.SourcePanel.Position = [581 585 277 160];

            % Create SourceTypeDropDownLabel
            app.SourceTypeDropDownLabel = uilabel(app.SourcePanel);
            app.SourceTypeDropDownLabel.HorizontalAlignment = 'right';
            app.SourceTypeDropDownLabel.FontSize = 14;
            app.SourceTypeDropDownLabel.Position = [9 25 83 22];
            app.SourceTypeDropDownLabel.Text = 'Source Type';

            % Create SourceTypeDropDown
            app.SourceTypeDropDown = uidropdown(app.SourcePanel);
            app.SourceTypeDropDown.Items = {'Parallel Beam', 'Cone Beam'};
            app.SourceTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @SourceTypeDropDownValueChanged, true);
            app.SourceTypeDropDown.Tooltip = {'This selects the type of ray configuration. '; ''; 'Change this value to observe the effect on the figure (left).'};
            app.SourceTypeDropDown.FontSize = 14;
            app.SourceTypeDropDown.Position = [107 25 150 22];
            app.SourceTypeDropDown.Value = 'Parallel Beam';

            % Create Source1DropDownLabel
            app.Source1DropDownLabel = uilabel(app.SourcePanel);
            app.Source1DropDownLabel.HorizontalAlignment = 'right';
            app.Source1DropDownLabel.FontSize = 14;
            app.Source1DropDownLabel.Tooltip = {'The X-ray source used to irradiate the phantom with X-rays and detect on the other side.'};
            app.Source1DropDownLabel.Position = [6 95 61 22];
            app.Source1DropDownLabel.Text = 'Source 1';

            % Create Source1DropDown
            app.Source1DropDown = uidropdown(app.SourcePanel);
            app.Source1DropDown.Items = {'Low Energy (40 kvp)', 'High Energy (80 kvp)'};
            app.Source1DropDown.ItemsData = {'Low Energy (40 kvp)', 'High Energy (80 kvp)'};
            app.Source1DropDown.FontSize = 14;
            app.Source1DropDown.Position = [76 95 125 22];
            app.Source1DropDown.Value = 'Low Energy (40 kvp)';

            % Create SourceLoadButton
            app.SourceLoadButton = uibutton(app.SourcePanel, 'push');
            app.SourceLoadButton.ButtonPushedFcn = createCallbackFcn(app, @SourceLoadButtonPushed, true);
            app.SourceLoadButton.FontSize = 14;
            app.SourceLoadButton.Tooltip = {'Load a ''.mat'' file containing the variable ''source'', to run the simulation with.'};
            app.SourceLoadButton.Position = [205 69 66 23];
            app.SourceLoadButton.Text = 'Load';

            % Create Source2DropDownLabel
            app.Source2DropDownLabel = uilabel(app.SourcePanel);
            app.Source2DropDownLabel.HorizontalAlignment = 'right';
            app.Source2DropDownLabel.FontSize = 14;
            app.Source2DropDownLabel.Tooltip = {'Optional second source, used for dual energy simulations'};
            app.Source2DropDownLabel.Position = [6 70 61 22];
            app.Source2DropDownLabel.Text = 'Source 2';

            % Create Source2DropDown
            app.Source2DropDown = uidropdown(app.SourcePanel);
            app.Source2DropDown.Items = {'None', 'Low Energy (40 kvp)', 'High Energy (80 kvp)'};
            app.Source2DropDown.ItemsData = {'None', 'Low Energy (40 kvp)', 'High Energy (80 kvp)'};
            app.Source2DropDown.FontSize = 14;
            app.Source2DropDown.Position = [76 70 125 22];
            app.Source2DropDown.Value = 'None';

            % Create ImagePanel
            app.ImagePanel = uipanel(app.RunTab);
            app.ImagePanel.AutoResizeChildren = 'off';
            app.ImagePanel.Position = [0 7 582 738];

            % Create DistToDetectorLine
            app.DistToDetectorLine = uiimage(app.ImagePanel);
            app.DistToDetectorLine.ImageClickedFcn = createCallbackFcn(app, @DistToDetectorLineImageClicked, true);
            app.DistToDetectorLine.Tooltip = {'Select this to view the distance between source and detector selection'};
            app.DistToDetectorLine.Position = [-17 185 100 449];
            app.DistToDetectorLine.ImageSource = fullfile(pathToMLAPP, 'graphics', 'distance.svg');

            % Create RaysImage
            app.RaysImage = uiimage(app.ImagePanel);
            app.RaysImage.ImageClickedFcn = createCallbackFcn(app, @ToggleSourcePanelVisibility, true);
            app.RaysImage.Tooltip = {'Select this to view the source options'};
            app.RaysImage.Position = [72 210 464 416];
            app.RaysImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'parallel_rays.svg');

            % Create RotationImage
            app.RotationImage = uiimage(app.ImagePanel);
            app.RotationImage.ImageClickedFcn = createCallbackFcn(app, @RotationImageClicked, true);
            app.RotationImage.Tooltip = {'Select this to view the number of rotations input.'; ''; 'The source and detector will be rotated around the phantom at a set angle. '; ''; 'This is set to be 360 degrees.'};
            app.RotationImage.Position = [43 646 217 89];
            app.RotationImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'rotation_arrow.svg');

            % Create ClickonanobjecttochangeitLabel
            app.ClickonanobjecttochangeitLabel = uilabel(app.ImagePanel);
            app.ClickonanobjecttochangeitLabel.HorizontalAlignment = 'center';
            app.ClickonanobjecttochangeitLabel.WordWrap = 'on';
            app.ClickonanobjecttochangeitLabel.FontSize = 24;
            app.ClickonanobjecttochangeitLabel.Position = [384 646 193 108];
            app.ClickonanobjecttochangeitLabel.Text = 'Click on an object to change it!';

            % Create DistToDetectorLabel
            app.DistToDetectorLabel = uilabel(app.ImagePanel);
            app.DistToDetectorLabel.HorizontalAlignment = 'center';
            app.DistToDetectorLabel.FontSize = 14;
            app.DistToDetectorLabel.Position = [43 571 119 34];
            app.DistToDetectorLabel.Text = {'Distance between'; 'Source & Detector'};

            % Create DistToDetectorField
            app.DistToDetectorField = uieditfield(app.ImagePanel, 'numeric');
            app.DistToDetectorField.LowerLimitInclusive = 'off';
            app.DistToDetectorField.Limits = [0 Inf];
            app.DistToDetectorField.FontSize = 14;
            app.DistToDetectorField.Position = [54 547 46 22];
            app.DistToDetectorField.Value = 100;

            % Create DistToDetectorUnits
            app.DistToDetectorUnits = uidropdown(app.ImagePanel);
            app.DistToDetectorUnits.Items = {'m', 'cm', 'mm'};
            app.DistToDetectorUnits.Editable = 'on';
            app.DistToDetectorUnits.ValueChangedFcn = createCallbackFcn(app, @UnitsValueChanged, true);
            app.DistToDetectorUnits.FontSize = 14;
            app.DistToDetectorUnits.BackgroundColor = [1 1 1];
            app.DistToDetectorUnits.Position = [98 547 56 22];
            app.DistToDetectorUnits.Value = 'cm';

            % Create SourceImage
            app.SourceImage = uiimage(app.ImagePanel);
            app.SourceImage.ImageClickedFcn = createCallbackFcn(app, @ToggleSourcePanelVisibility, true);
            app.SourceImage.Tooltip = {'Select this to view the source options'};
            app.SourceImage.Position = [254 633 100 100];
            app.SourceImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'source.svg');

            % Create WireImage
            app.WireImage = uiimage(app.ImagePanel);
            app.WireImage.ImageClickedFcn = createCallbackFcn(app, @ToggleReconstructionPanelVisibility, true);
            app.WireImage.Tooltip = {'Select this to view the reconstruction options'};
            app.WireImage.Position = [322 76 100 109];
            app.WireImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'wire.svg');

            % Create PCImage
            app.PCImage = uiimage(app.ImagePanel);
            app.PCImage.ImageClickedFcn = createCallbackFcn(app, @ToggleReconstructionPanelVisibility, true);
            app.PCImage.Tooltip = {'Select this to view the reconstruction options'};
            app.PCImage.Position = [405 10 169 157];
            app.PCImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'PC.svg');

            % Create DetectorArrayImage
            app.DetectorArrayImage = uiimage(app.ImagePanel);
            app.DetectorArrayImage.ImageClickedFcn = createCallbackFcn(app, @ToggleDetectorPanelVisibility, true);
            app.DetectorArrayImage.Tooltip = {'Select this to view the detector options'};
            app.DetectorArrayImage.Position = [61 140 502 149];
            app.DetectorArrayImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'flat_detector.svg');

            % Create RunButton
            app.RunButton = uibutton(app.ImagePanel, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.Icon = fullfile(pathToMLAPP, 'graphics', 'Play.png');
            app.RunButton.FontSize = 36;
            app.RunButton.Tooltip = {'Run the simulation!'};
            app.RunButton.Position = [402 608 158 58];
            app.RunButton.Text = 'Run';

            % Create NumberofRotationsEditField
            app.NumberofRotationsEditField = uieditfield(app.ImagePanel, 'numeric');
            app.NumberofRotationsEditField.Limits = [1 Inf];
            app.NumberofRotationsEditField.RoundFractionalValues = 'on';
            app.NumberofRotationsEditField.FontSize = 14;
            app.NumberofRotationsEditField.Tooltip = {'Number of rotations that will be simulated. The source and detector will be rotated around the phantom at a set angle. This is set to be 360 degrees.'};
            app.NumberofRotationsEditField.Position = [218 660 50 22];
            app.NumberofRotationsEditField.Value = 180;

            % Create ScatterImage
            app.ScatterImage = uiimage(app.ImagePanel);
            app.ScatterImage.ImageClickedFcn = createCallbackFcn(app, @ToggleScatterPanelVisibility, true);
            app.ScatterImage.Tooltip = {'Select this to view the scatter options'};
            app.ScatterImage.Position = [181 306 100 100];
            app.ScatterImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'scatter_rays.svg');

            % Create ScatterPanel
            app.ScatterPanel = uipanel(app.ImagePanel);
            app.ScatterPanel.AutoResizeChildren = 'off';
            app.ScatterPanel.Title = 'Scatter (Optional)';
            app.ScatterPanel.Visible = 'off';
            app.ScatterPanel.FontSize = 18;
            app.ScatterPanel.Position = [4 2 320 165];

            % Create ScatterTypeListBoxLabel
            app.ScatterTypeListBoxLabel = uilabel(app.ScatterPanel);
            app.ScatterTypeListBoxLabel.HorizontalAlignment = 'right';
            app.ScatterTypeListBoxLabel.FontSize = 14;
            app.ScatterTypeListBoxLabel.Position = [50 110 83 22];
            app.ScatterTypeListBoxLabel.Text = 'Scatter Type';

            % Create ScatterTypeListBox
            app.ScatterTypeListBox = uilistbox(app.ScatterPanel);
            app.ScatterTypeListBox.Items = {'None', 'Fast', 'Slow'};
            app.ScatterTypeListBox.Tooltip = {'This determines which scatter algorithm to use. '; ''; 'Fast is a convolutional algorithm that is based on Monte Carlo simulations.'; ''; 'Slow is an experimental implementation, estimating the scatter through sampling along each ray.'};
            app.ScatterTypeListBox.FontSize = 14;
            app.ScatterTypeListBox.Position = [148 60 100 74];
            app.ScatterTypeListBox.Value = 'None';

            % Create ScatterFactorSpinnerLabel
            app.ScatterFactorSpinnerLabel = uilabel(app.ScatterPanel);
            app.ScatterFactorSpinnerLabel.HorizontalAlignment = 'right';
            app.ScatterFactorSpinnerLabel.FontSize = 14;
            app.ScatterFactorSpinnerLabel.Position = [46 22 93 22];
            app.ScatterFactorSpinnerLabel.Text = 'Scatter Factor';

            % Create ScatterFactorSpinner
            app.ScatterFactorSpinner = uispinner(app.ScatterPanel);
            app.ScatterFactorSpinner.Limits = [0 10];
            app.ScatterFactorSpinner.RoundFractionalValues = 'on';
            app.ScatterFactorSpinner.FontSize = 14;
            app.ScatterFactorSpinner.Tooltip = {'How much scatter to use. '; ''; 'For Fast, this increases the amplitude of the scatter in the image. Increasing this value has no effect on the accuracy of the scatter estimation.'; ''; 'For slow, this increases how many samples we take at each point. Increasing this increases the accuracy of the scatter estimation.'};
            app.ScatterFactorSpinner.Position = [172 21 56 22];
            app.ScatterFactorSpinner.Value = 1;

            % Create NumberofRotationsLabel
            app.NumberofRotationsLabel = uilabel(app.ImagePanel);
            app.NumberofRotationsLabel.FontSize = 14;
            app.NumberofRotationsLabel.Tooltip = {'Number of rotations that will be simulated. The source and detector will be rotated around the phantom at a set angle. '; ''; 'With a cone beam, this is the number of rotations within 360 degrees.'; ''; 'For a parallel beam, this is the number of rotations in 180 degrees.'};
            app.NumberofRotationsLabel.Position = [87 660 133 22];
            app.NumberofRotationsLabel.Text = 'Number of Rotations';

            % Create PhantomImage
            app.PhantomImage = uiimage(app.ImagePanel);
            app.PhantomImage.ImageClickedFcn = createCallbackFcn(app, @TogglePhantomPanelVisibility, true);
            app.PhantomImage.Tooltip = {'Select this to view the phantom options.'; ''; 'A phantom is the irradiated object used in the simulation.'};
            app.PhantomImage.Position = [252 342 104 174];
            app.PhantomImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'SheppLogan_Phantom.svg');

            % Create RunContextMenu
            app.RunContextMenu = uicontextmenu(app.UIFigure);

            % Create LoadStateInContextMenu
            app.LoadStateInContextMenu = uimenu(app.RunContextMenu);
            app.LoadStateInContextMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadStateSelected, true);
            app.LoadStateInContextMenu.Text = 'Load State';

            % Create SaveStateInContextMenu
            app.SaveStateInContextMenu = uimenu(app.RunContextMenu);
            app.SaveStateInContextMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveStateSelected, true);
            app.SaveStateInContextMenu.Text = 'Save State';

            % Create RunInContextMenu
            app.RunInContextMenu = uimenu(app.RunContextMenu);
            app.RunInContextMenu.MenuSelectedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunInContextMenu.Text = 'Run';

            % Create ResetInContextMenu
            app.ResetInContextMenu = uimenu(app.RunContextMenu);
            app.ResetInContextMenu.MenuSelectedFcn = createCallbackFcn(app, @ResetMenuSelected, true);
            app.ResetInContextMenu.Text = 'Reset';

            % Create ExporttoScriptMenu
            app.ExporttoScriptMenu = uimenu(app.RunContextMenu);
            app.ExporttoScriptMenu.MenuSelectedFcn = createCallbackFcn(app, @ExporttoScriptMenuSelected, true);
            app.ExporttoScriptMenu.Text = 'Export to Script';
            
            % Assign app.RunContextMenu
            app.UIFigure.ContextMenu = app.RunContextMenu;
            app.TabGroup.ContextMenu = app.RunContextMenu;
            app.RunTab.ContextMenu = app.RunContextMenu;
            app.ResultsPanel.ContextMenu = app.RunContextMenu;
            app.ImagePanel.ContextMenu = app.RunContextMenu;

            % Create DetectorContextMenu
            app.DetectorContextMenu = uicontextmenu(app.UIFigure);

            % Create DetectorHelpMenu_run
            app.DetectorHelpMenu_run = uimenu(app.DetectorContextMenu);
            app.DetectorHelpMenu_run.MenuSelectedFcn = createCallbackFcn(app, @DetectorContextMenuSelected, true);
            app.DetectorHelpMenu_run.Text = 'Detector Help';
            
            % Assign app.DetectorContextMenu
            app.SensorTypeDropDownLabel.ContextMenu = app.DetectorContextMenu;
            app.SensorTypeDropDown.ContextMenu = app.DetectorContextMenu;
            app.PixelWidthLabel.ContextMenu = app.DetectorContextMenu;
            app.PixelWidthField.ContextMenu = app.DetectorContextMenu;
            app.PixelWidthUnits.ContextMenu = app.DetectorContextMenu;
            app.NumberofPixelsEditFieldLabel.ContextMenu = app.DetectorContextMenu;
            app.NumberofPixelsEditField.ContextMenu = app.DetectorContextMenu;
            app.DetectorShapeDropDownLabel.ContextMenu = app.DetectorContextMenu;
            app.DetectorShapeDropDown.ContextMenu = app.DetectorContextMenu;
            app.DistToDetectorLine.ContextMenu = app.DetectorContextMenu;
            app.RotationImage.ContextMenu = app.DetectorContextMenu;
            app.DetectorArrayImage.ContextMenu = app.DetectorContextMenu;

            % Create PhantomContextMenu
            app.PhantomContextMenu = uicontextmenu(app.UIFigure);

            % Create LoadPhantomMenu
            app.LoadPhantomMenu = uimenu(app.PhantomContextMenu);
            app.LoadPhantomMenu.MenuSelectedFcn = createCallbackFcn(app, @PhantomLoadButtonPushed, true);
            app.LoadPhantomMenu.Text = 'Load Phantom';

            % Create PhantomHelpMenu_run
            app.PhantomHelpMenu_run = uimenu(app.PhantomContextMenu);
            app.PhantomHelpMenu_run.MenuSelectedFcn = createCallbackFcn(app, @PhantomHelpMenu_runSelected, true);
            app.PhantomHelpMenu_run.Text = 'Phantom Help';
            
            % Assign app.PhantomContextMenu
            app.PhantomPanel.ContextMenu = app.PhantomContextMenu;
            app.PhantomListBoxLabel.ContextMenu = app.PhantomContextMenu;
            app.PhantomListBox.ContextMenu = app.PhantomContextMenu;
            app.VoxelSizeEditFieldLabel.ContextMenu = app.PhantomContextMenu;
            app.VoxelSizeEditField.ContextMenu = app.PhantomContextMenu;
            app.VoxelSizeUnits.ContextMenu = app.PhantomContextMenu;
            app.PhantomImage.ContextMenu = app.PhantomContextMenu;

            % Create SourceContextMenu
            app.SourceContextMenu = uicontextmenu(app.UIFigure);

            % Create LoadSourceMenu
            app.LoadSourceMenu = uimenu(app.SourceContextMenu);
            app.LoadSourceMenu.MenuSelectedFcn = createCallbackFcn(app, @SourceLoadButtonPushed, true);
            app.LoadSourceMenu.Text = 'Load Source';

            % Create SourceHelpMenu_run
            app.SourceHelpMenu_run = uimenu(app.SourceContextMenu);
            app.SourceHelpMenu_run.MenuSelectedFcn = createCallbackFcn(app, @SourceHelpMenu_runSelected, true);
            app.SourceHelpMenu_run.Text = 'Source Help';
            
            % Assign app.SourceContextMenu
            app.SourcePanel.ContextMenu = app.SourceContextMenu;
            app.SourceTypeDropDownLabel.ContextMenu = app.SourceContextMenu;
            app.SourceTypeDropDown.ContextMenu = app.SourceContextMenu;
            app.Source1DropDownLabel.ContextMenu = app.SourceContextMenu;
            app.Source1DropDown.ContextMenu = app.SourceContextMenu;
            app.Source2DropDownLabel.ContextMenu = app.SourceContextMenu;
            app.Source2DropDown.ContextMenu = app.SourceContextMenu;
            app.RaysImage.ContextMenu = app.SourceContextMenu;
            app.SourceImage.ContextMenu = app.SourceContextMenu;

            % Create ReconImageContextMenu
            app.ReconImageContextMenu = uicontextmenu(app.UIFigure);

            % Create RunSimulationMenu
            app.RunSimulationMenu = uimenu(app.ReconImageContextMenu);
            app.RunSimulationMenu.MenuSelectedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunSimulationMenu.Text = 'Run Simulation';

            % Create ReconSaveImageasMenu
            app.ReconSaveImageasMenu = uimenu(app.ReconImageContextMenu);
            app.ReconSaveImageasMenu.Text = 'Save Image as';

            % Create ReconstructionMenu
            app.ReconstructionMenu = uimenu(app.ReconSaveImageasMenu);
            app.ReconstructionMenu.MenuSelectedFcn = createCallbackFcn(app, @ReconSaveImageSelected, true);
            app.ReconstructionMenu.Text = 'Reconstruction';

            % Create SinogramMenu
            app.SinogramMenu = uimenu(app.ReconSaveImageasMenu);
            app.SinogramMenu.MenuSelectedFcn = createCallbackFcn(app, @SinogramSaveImageSelected, true);
            app.SinogramMenu.Text = 'Sinogram';

            % Create ReconOpeninNewWindowMenu
            app.ReconOpeninNewWindowMenu = uimenu(app.ReconImageContextMenu);
            app.ReconOpeninNewWindowMenu.Text = 'Open in New Window';

            % Create ReconstructionMenu_2
            app.ReconstructionMenu_2 = uimenu(app.ReconOpeninNewWindowMenu);
            app.ReconstructionMenu_2.MenuSelectedFcn = createCallbackFcn(app, @ReconOpeninNewWindowMenuSelected, true);
            app.ReconstructionMenu_2.Text = 'Reconstruction';

            % Create SinogramMenu_2
            app.SinogramMenu_2 = uimenu(app.ReconOpeninNewWindowMenu);
            app.SinogramMenu_2.MenuSelectedFcn = createCallbackFcn(app, @SinogramOpeninNewWindowMenuSelected, true);
            app.SinogramMenu_2.Text = 'Sinogram';

            % Create OpeninImageViewerMenu
            app.OpeninImageViewerMenu = uimenu(app.ReconImageContextMenu);
            app.OpeninImageViewerMenu.Text = 'Open in Image Viewer';

            % Create ReconstructionMenu_3
            app.ReconstructionMenu_3 = uimenu(app.OpeninImageViewerMenu);
            app.ReconstructionMenu_3.MenuSelectedFcn = createCallbackFcn(app, @OpeninImageViewerMenuSelected, true);
            app.ReconstructionMenu_3.Text = 'Reconstruction';

            % Create SinogramMenu_3
            app.SinogramMenu_3 = uimenu(app.OpeninImageViewerMenu);
            app.SinogramMenu_3.MenuSelectedFcn = createCallbackFcn(app, @OpeninImageViewerMenuSelected, true);
            app.SinogramMenu_3.Text = 'Sinogram';

            % Create ReconImageHelpMenu
            app.ReconImageHelpMenu = uimenu(app.ReconImageContextMenu);
            app.ReconImageHelpMenu.Text = 'Help';
            
            % Assign app.ReconImageContextMenu
            app.ReconstructionImage.ContextMenu = app.ReconImageContextMenu;

            % Create ReconstructionContextMenu
            app.ReconstructionContextMenu = uicontextmenu(app.UIFigure);

            % Create ReconstructionHelpMenu
            app.ReconstructionHelpMenu = uimenu(app.ReconstructionContextMenu);
            app.ReconstructionHelpMenu.MenuSelectedFcn = createCallbackFcn(app, @ReconstructionHelpMenuSelected, true);
            app.ReconstructionHelpMenu.Tooltip = {'Get help on the reconstruction'};
            app.ReconstructionHelpMenu.Text = 'Reconstruction Help';
            
            % Assign app.ReconstructionContextMenu
            app.ReconstructionPanel.ContextMenu = app.ReconstructionContextMenu;
            app.FilterListBoxLabel.ContextMenu = app.ReconstructionContextMenu;
            app.FilterListBox.ContextMenu = app.ReconstructionContextMenu;
            app.InterpolationDropDownLabel.ContextMenu = app.ReconstructionContextMenu;
            app.InterpolationDropDown.ContextMenu = app.ReconstructionContextMenu;
            app.WireImage.ContextMenu = app.ReconstructionContextMenu;
            app.PCImage.ContextMenu = app.ReconstructionContextMenu;

            % Create ScatterContextMenu
            app.ScatterContextMenu = uicontextmenu(app.UIFigure);

            % Create ScatterHelpMenu
            app.ScatterHelpMenu = uimenu(app.ScatterContextMenu);
            app.ScatterHelpMenu.MenuSelectedFcn = createCallbackFcn(app, @ScatterContextMenuSelected, true);
            app.ScatterHelpMenu.Text = 'Scatter Help';
            
            % Assign app.ScatterContextMenu
            app.ScatterImage.ContextMenu = app.ScatterContextMenu;
            app.ScatterPanel.ContextMenu = app.ScatterContextMenu;
            app.ScatterTypeListBoxLabel.ContextMenu = app.ScatterContextMenu;
            app.ScatterTypeListBox.ContextMenu = app.ScatterContextMenu;
            app.ScatterFactorSpinnerLabel.ContextMenu = app.ScatterContextMenu;
            app.ScatterFactorSpinner.ContextMenu = app.ScatterContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = gui

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.UIFigure)
            else

                % Focus the running singleton app
                figure(runningApp.UIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end