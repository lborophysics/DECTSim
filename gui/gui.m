classdef gui < matlab.apps.AppBase
    %GUI DECTSim GUI
    %   The GUI for DECTSim program

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        FileMenu                        matlab.ui.container.Menu
        LoadMenu                        matlab.ui.container.Menu
        SaveMenu                        matlab.ui.container.Menu
        SaveasMenu                      matlab.ui.container.Menu
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
        DistToDetectorLine              matlab.ui.control.Image
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
        SourceNumberSwitch              matlab.ui.control.Switch
        ReconstructedImageLabel         matlab.ui.control.Label
        SinogramLabel                   matlab.ui.control.Label
        SinogramImage                   matlab.ui.control.Image
        ReconstructionImage             matlab.ui.control.Image
        ReconstructionPanel             matlab.ui.container.Panel
        InterpolationDropDown           matlab.ui.control.DropDown
        InterpolationDropDownLabel      matlab.ui.control.Label
        FilterListBox                   matlab.ui.control.ListBox
        FilterListBoxLabel              matlab.ui.control.Label
        SourceTab                       matlab.ui.container.Tab
        PhantomTab                      matlab.ui.container.Tab
        DetectorTab                     matlab.ui.container.Tab
        SensorsPanel                    matlab.ui.container.Panel
        PixelArrayPanel                 matlab.ui.container.Panel
        MovementPanel                   matlab.ui.container.Panel
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
        LoadPhantomInContextMenu        matlab.ui.container.Menu
        SourceHelpMenu_run              matlab.ui.container.Menu
        ReconImageContextMenu           matlab.ui.container.ContextMenu
        ReconSaveImageasMenu            matlab.ui.container.Menu
        ReconOpeninNewWindowMenu        matlab.ui.container.Menu
        ReconImageHelpMenu              matlab.ui.container.Menu
        SinogramImageContextMenu        matlab.ui.container.ContextMenu
        SinogramSaveImageasMenu         matlab.ui.container.Menu
        SinogramOpeninNewWindowMenu     matlab.ui.container.Menu
        SinogramImageHelpMenu           matlab.ui.container.Menu
        ReconstructionContextMenu       matlab.ui.container.ContextMenu
        ReconstructionHelpMenu          matlab.ui.container.Menu
        ScatterContextMenu              matlab.ui.container.ContextMenu
        ScatterHelpMenu                 matlab.ui.container.Menu
    end

    
    properties (Access = private)
        recon_fig    % If the reconstruction figure is open this is a handle
        sinogram_fig % If the sinogram figure is open this is a handle

        recon_image1       % A way to store the most recent reconstruction for source 1
        sinogram_image1    % A way to store the most recent sinogram for source 1
        recon_image2       % A way to store the most recent reconstruction for source 2
        sinogram_image2    % A way to store the most recent sinogram for source 2

        phantom_paths = {} % A cell array of additional phantoms added by the user
    end

    methods (Access = private, Static)
        function colourImage = greyToColour(image)
            colourImage = cat(3, image, image, image);
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Image clicked function: RaysImage, SourceImage
        function ToggleSourcePanelVisibility(app, event)
            if strcmp(app.SourcePanel.Visible, 'off')
                app.SourcePanel.Visible = 'on';
            else
                app.SourcePanel.Visible = 'off';
            end
        end

        % Image clicked function: PhantomImage
        function TogglePhantomPanelVisibility(app, event)
            if strcmp(app.PhantomPanel.Visible, 'off')
                app.PhantomPanel.Visible = 'on';
            else
                app.PhantomPanel.Visible = 'off';
            end
        end

        % Image clicked function: DetectorArrayImage
        function ToggleDetectorPanelVisibility(app, event)
            if strcmp(app.DetectorPanel.Visible, 'off')
                app.DetectorPanel.Visible = 'on';
            else
                app.DetectorPanel.Visible = 'off';
            end
        end

        % Image clicked function: PCImage, WireImage
        function ToggleReconstructionPanelVisibility(app, event)
            if strcmp(app.ReconstructionPanel.Visible, 'off')
                app.ReconstructionPanel.Visible = 'on';
            else
                app.ReconstructionPanel.Visible = 'off';
            end
        end

        % Image clicked function: ScatterImage
        function ToggleScatterPanelVisibility(app, event)
            if strcmp(app.ScatterPanel.Visible, 'off')
                app.ScatterPanel.Visible = 'on';
            else
                app.ScatterPanel.Visible = 'off';
            end
        end

        % Image clicked function: DistToDetectorLine
        function DistToDetectorLineImageClicked(app, event)
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
        function RotationImageClicked(app, event)
            if strcmp(app.NumberofRotationsEditField.Visible, 'off')
                app.NumberofRotationsEditField.Visible = 'on';
                app.NumberofRotationsLabel.Visible = 'on';
            else
                app.NumberofRotationsEditField.Visible = 'off';
                app.NumberofRotationsLabel.Visible = 'off';
            end
        end

        % Callback function: RunButton, RunInContextMenu
        function RunButtonPushed(app, event)
             % Run the simulation
             % Get the file path for locating examples
            pathToMLAPP = fileparts(mfilename('fullpath'));
            runningdlg = uiprogressdlg(app.UIFigure, 'Title', 'Running Simulation', 'Indeterminate', 'on');
            drawnow;

            % Get the source
            LowEnergySource = load(fullfile(pathToMLAPP, 'SourceExample40kvp.mat'), 'source').source;
            HighEnergySource = load(fullfile(pathToMLAPP, 'SourceExample80kvp.mat'), 'source').source;
            source1_idx = app.Source1DropDown.ValueIndex;
            if source1_idx == 1
                source1 = LowEnergySource;
            elseif source1_idx == 2
                source1 = HighEnergySource;
            else
                path = app.Source1DropDown.ItemsData{source1_idx};
                source1 = load(path, 'source').source;
            end

            source2_idx = app.Source2DropDown.ValueIndex;
            has_source2 = true;
            if source2_idx == 1
                has_source2 = false;
            elseif source2_idx == 2
                source2 = LowEnergySource;
            elseif source2_idx == 3
                source2 = HighEnergySource;
            else
                path = app.Source2DropDown.ItemsData{source2_idx};
                source2 = load(path, 'source').source;
            end

            % Get the phantom
            phantom_idx = app.PhantomListBox.ValueIndex;
            PhantomEx1 = load(fullfile(pathToMLAPP, 'PhantomExample1.mat'), 'phantom').phantom;
            PhantomEx2 = load(fullfile(pathToMLAPP, 'PhantomExample2.mat'), 'phantom').phantom;
            if phantom_idx == 1
                phantom = PhantomEx1;
            elseif phantom_idx == 2
                phantom = PhantomEx2;
            else % phantom_idx > 2
                index = app.PhantomListBox.ValueIndex;
                path = app.PhantomListBox.ItemsData{index};
                phantom = load(path, 'phantom').phantom;
            end
            voxel_size = app.VoxelSizeEditField.Value;
            voxel_unit = units.(app.VoxelSizeUnits.Value);
            
            phantom = phantom.update_voxel_size(voxel_size * voxel_unit);

            % Get the detector
            detector_type = app.DetectorShapeDropDown.Value;           
            num_rotations = app.NumberofRotationsEditField.Value;

            dist_to_detector = app.DistToDetectorField.Value;
            dist_unit = units.(app.DistToDetectorUnits.Value);
            dist_to_detector = dist_to_detector * dist_unit;
            
            
            source_type = app.SourceTypeDropDown.Value;
            if strcmp(source_type, 'Parallel Beam')
                g = parallel_gantry(dist_to_detector, num_rotations);
            else
                g = gantry(dist_to_detector, num_rotations); % Should be cone beam
            end

            pixel_size = app.PixelWidthField.Value;
            pixel_unit = units.(app.PixelWidthUnits.Value);
            
            pixel_dims = [pixel_size pixel_size] .* pixel_unit;
            num_pixels = [app.NumberofPixelsEditField.Value, 1];
            if strcmp(detector_type, 'Flat')
                darray = flat_detector(pixel_dims, num_pixels);
            else
                darray = curved_detector(pixel_dims, num_pixels);
            end
            
            [emin, emax] = source1.get_energy_range();
            num_bins = ceil(emax - emin);
            sensor = ideal_sensor([emin, emax], num_bins);
            
            d = detector(g, darray, sensor);

            % Get the scatter settings
            scatter_type = lower(app.ScatterTypeListBox.Value);
            scatter_factor = app.ScatterFactorSpinner.Value;

            % Get the reconstruction information
            filter = app.FilterListBox.Value;
            interpolation = app.InterpolationDropDown.Value;
            scan_angles = rad2deg(g.scan_angles);

            % Compute the sinogram
            sinogram = squeeze(compute_sinogram(source1, phantom, d, scatter_type, scatter_factor));
            if has_source2
                sinogram2 = squeeze(compute_sinogram(source2, phantom, d, scatter_type, scatter_factor));
                
                % Reconstruct the image
                recon2 = iradon(sinogram2, scan_angles, interpolation, filter);
                app.sinogram_image2 = app1.greyToColour(mat2gray(sinogram2));
                app.recon_image2 = app1.greyToColour(mat2gray(recon2));
            else
                app.sinogram_image2 = []; app.recon_image2 = [];
            end
            % Reconstruct the image
            recon = iradon(sinogram, scan_angles, interpolation, filter);
            app.sinogram_image1 = app1.greyToColour(mat2gray(sinogram));
            app.recon_image1 = app1.greyToColour(mat2gray(recon));
            
            % Set the image from the sinogram and reconstruction
            app.SinogramImage.ImageSource = app.sinogram_image1;
            app.ReconstructionImage.ImageSource = app.recon_image1;

            % Display the result
            runningdlg.close();
        end

        % Image clicked function: ReconstructionImage
        function ReconstructionImageClicked(app, event)
            type = get(gcbf, 'SelectionType');
            if strcmp(type, 'open')
                % Handle double-click action here
                fig_open = ~ishandle(app.recon_fig);
                if isempty(fig_open) || fig_open
                    app.recon_fig = figure("Name","Reconstucted Image");
                    imshow(app.recon_image1);
                else
                    figure(app.recon_fig);
                end
            end
        end

        % Image clicked function: SinogramImage
        function SinogramImageClicked(app, event)
            type = get(gcbf, 'SelectionType');
            if strcmp(type, 'open')
                % Handle double-click action here
                fig_open = ~ishandle(app.sinogram_fig);
                if isempty(fig_open) || fig_open
                    app.sinogram_fig = figure("Name","Sinogram");
                    imshow(app.sinogram_image1);
                else
                    figure(app.sinogram_fig);
                end
            end
        end

        % Menu selected function: ReconSaveImageasMenu
        function ReconSaveImageasMenuSelected(app, event)
            if isempty(app.recon_image1)
                errordlg('No file to save', 'Invalid file');
                return
            end 
            [file,path] = uiputfile(...
                {'*.png;*.jpeg','Image files'}, ...
                "Save Reconstructed Image");
            if file == 0 || path == 0; return; end % Nothing selected
            imwrite(app.recon_image1, fullfile(path, file))
        end

        % Menu selected function: SinogramSaveImageasMenu
        function SinogramSaveImageasMenuSelected(app, event)
            if isempty(app.sinogram_image1)
                errordlg('No file to save', 'Invalid file');
                return
            end 
            [file,path] = uiputfile(...
                {'*.png;*.jpeg','Image files'}, ...
                "Save Sinogram");
            if file == 0 || path == 0; return; end % Nothing selected
            imwrite(app.sinogram_image1, fullfile(path, file))
        end

        % Menu selected function: ReconOpeninNewWindowMenu
        function ReconOpeninNewWindowMenuSelected(app, event)
            fig_open = ~ishandle(app.recon_fig);
            if isempty(fig_open) || fig_open
                app.recon_fig = figure("Name","Reconstucted Image");
                imshow(app.recon_image1);
            else
                figure(app.recon_fig);
            end
        end

        % Menu selected function: SinogramOpeninNewWindowMenu
        function SinogramOpeninNewWindowMenuSelected(app, event)
            fig_open = ~ishandle(app.sinogram_fig);
            if isempty(fig_open) || fig_open
                app.sinogram_fig = figure("Name","Sinogram");
                imshow(app.sinogram_image1);
            else
                figure(app.sinogram_fig);
            end
        end

        % Value changed function: SourceTypeDropDown
        function SourceTypeDropDownValueChanged(app, event)
            source_type = app.SourceTypeDropDown.Value;
            pathToMLAPP = fileparts(mfilename('fullpath'));
            if strcmp(source_type, 'Parallel Beam')
                app.RaysImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'parallel_rays.svg');
            else
                app.RaysImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'curved_rays.svg');
            end
        end

        % Value changed function: DetectorShapeDropDown
        function DetectorShapeDropDownValueChanged(app, event)
            detector_type = app.DetectorShapeDropDown.Value;
            pathToMLAPP = fileparts(mfilename('fullpath'));
            if strcmp(detector_type, 'Flat')
                app.DetectorArrayImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'flat_detector.svg');
            else
                app.DetectorArrayImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'curved_detector.svg');
            end
        end

        % Callback function: LoadPhantomMenu, PhantomLoadButton
        function PhantomLoadButtonPushed(app, event)
            [file,path] = uigetfile('*.mat','Load Saved Phantom File');
            if ~(file == 0 || path == 0)
                [~, name, ~] = fileparts(file);
                app.PhantomListBox.Items{end + 1} = name;
                app.PhantomListBox.ItemsData{end + 1} = fullfile(path, file);
            end
        end

        % Callback function: LoadPhantomInContextMenu, SourceLoadButton
        function SourceLoadButtonPushed(app, event)
            [file,path] = uigetfile('*.mat','Load Saved Source File');
            if ~(file == 0 || path == 0)
                [~, name, ~] = fileparts(file);
                app.Source1DropDown.Items{end+1} = name;
                app.Source2DropDown.Items{end+1} = name;
                app.Source1DropDown.ItemsData{end+1} = fullfile(path, file);
                app.Source2DropDown.ItemsData{end+1} = fullfile(path, file);
            end % Nothing selected
        end

        % Menu selected function: ResetInContextMenu, ResetMenu
        function ResetMenuSelected(app, event)
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
            app.sinogram_image1 = [];
            app.recon_image1 = [];
            app.SinogramImage.ImageSource = fullfile(pathToMLAPP, 'Initial Image.png');
            app.ReconstructionImage.ImageSource = fullfile(pathToMLAPP, 'Initial Image.png');
            
            % Reset the dropdowns
            app.Source1DropDown.Items = {'Low Energy (40 kvp)', 'High Energy (80 kvp)'};
            app.Source1DropDown.ItemsData = {'Low Energy (40 kvp)', 'High Energy (80 kvp)'};
            app.Source2DropDown.Items = {'None', 'Low Energy (40 kvp)', 'High Energy (80 kvp)'};
            app.Source2DropDown.ItemsData = {'None', 'Low Energy (40 kvp)', 'High Energy (80 kvp)'};
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

        % Value changed function: ShowDropDown, SourceNumberSwitch
        function SourceNumberSwitchValueChanged(app, event)
            value = app.SourceNumberSwitch.Value;
            if strcmp(value, 'Source 1') && ~isempty(app.sinogram_image1)
                app.SinogramImage.ImageSource = app.sinogram_image1;
                app.ReconstructionImage.ImageSource = app.recon_image1;
            elseif ~isempty(app.sinogram_image2)
                app.SinogramImage.ImageSource = app.sinogram_image2;
                app.ReconstructionImage.ImageSource = app.recon_image2;
            else
                app.SourceNumberSwitch.Value = 'Source 1';
                uialert(app.UIFigure, 'No Second Source available', 'Invalid Source Selection');
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

            % Create LoadMenu
            app.LoadMenu = uimenu(app.FileMenu);
            app.LoadMenu.Text = 'Load';

            % Create SaveMenu
            app.SaveMenu = uimenu(app.FileMenu);
            app.SaveMenu.Text = 'Save';

            % Create SaveasMenu
            app.SaveasMenu = uimenu(app.FileMenu);
            app.SaveasMenu.Text = 'Save as';

            % Create ExportMenu
            app.ExportMenu = uimenu(app.FileMenu);
            app.ExportMenu.Text = 'Export';

            % Create ResetMenu
            app.ResetMenu = uimenu(app.FileMenu);
            app.ResetMenu.MenuSelectedFcn = createCallbackFcn(app, @ResetMenuSelected, true);
            app.ResetMenu.Text = 'Reset';

            % Create HelpMenu
            app.HelpMenu = uimenu(app.UIFigure);
            app.HelpMenu.Text = 'Help';

            % Create DocumentationMenu
            app.DocumentationMenu = uimenu(app.HelpMenu);
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
            app.InterpolationDropDown.Items = {'linear', 'nearest', 'spline', 'pchip', 'v5cubic'};
            app.InterpolationDropDown.FontSize = 14;
            app.InterpolationDropDown.Position = [127 33 100 22];
            app.InterpolationDropDown.Value = 'linear';

            % Create ResultsPanel
            app.ResultsPanel = uipanel(app.RunTab);
            app.ResultsPanel.FontSize = 18;
            app.ResultsPanel.Position = [858 1 508 744];

            % Create ReconstructionImage
            app.ReconstructionImage = uiimage(app.ResultsPanel);
            app.ReconstructionImage.ImageClickedFcn = createCallbackFcn(app, @ReconstructionImageClicked, true);
            app.ReconstructionImage.Position = [157 30 345 683];
            app.ReconstructionImage.ImageSource = fullfile(pathToMLAPP, 'Initial Image.png');

            % Create SinogramImage
            app.SinogramImage = uiimage(app.ResultsPanel);
            app.SinogramImage.ImageClickedFcn = createCallbackFcn(app, @SinogramImageClicked, true);
            app.SinogramImage.Position = [1 0 153 713];
            app.SinogramImage.ImageSource = fullfile(pathToMLAPP, 'Initial Image.png');

            % Create SinogramLabel
            app.SinogramLabel = uilabel(app.ResultsPanel);
            app.SinogramLabel.FontSize = 18;
            app.SinogramLabel.Position = [3 718 82 23];
            app.SinogramLabel.Text = 'Sinogram';

            % Create ReconstructedImageLabel
            app.ReconstructedImageLabel = uilabel(app.ResultsPanel);
            app.ReconstructedImageLabel.FontSize = 18;
            app.ReconstructedImageLabel.Position = [330 718 176 23];
            app.ReconstructedImageLabel.Text = 'Reconstructed Image';

            % Create SourceNumberSwitch
            app.SourceNumberSwitch = uiswitch(app.ResultsPanel, 'slider');
            app.SourceNumberSwitch.Items = {'Source 1', 'Source 2'};
            app.SourceNumberSwitch.ValueChangedFcn = createCallbackFcn(app, @SourceNumberSwitchValueChanged, true);
            app.SourceNumberSwitch.FontSize = 18;
            app.SourceNumberSwitch.Position = [381 0 45 20];
            app.SourceNumberSwitch.Value = 'Source 1';

            % Create ShowDropDownLabel
            app.ShowDropDownLabel = uilabel(app.ResultsPanel);
            app.ShowDropDownLabel.HorizontalAlignment = 'right';
            app.ShowDropDownLabel.Position = [341 36 38 22];
            app.ShowDropDownLabel.Text = 'Show:';

            % Create ShowDropDown
            app.ShowDropDown = uidropdown(app.ResultsPanel);
            app.ShowDropDown.Items = {'Source 1', 'Source 2', 'Difference', 'Ratio'};
            app.ShowDropDown.ValueChangedFcn = createCallbackFcn(app, @SourceNumberSwitchValueChanged, true);
            app.ShowDropDown.Position = [394 36 100 22];
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
            app.SensorTypeDropDown.FontSize = 14;
            app.SensorTypeDropDown.Position = [140 14 110 22];
            app.SensorTypeDropDown.Value = 'Ideal';

            % Create PixelWidthLabel
            app.PixelWidthLabel = uilabel(app.DetectorPanel);
            app.PixelWidthLabel.HorizontalAlignment = 'center';
            app.PixelWidthLabel.FontSize = 14;
            app.PixelWidthLabel.Position = [36 93 75 22];
            app.PixelWidthLabel.Text = 'Pixel Width';

            % Create PixelWidthField
            app.PixelWidthField = uieditfield(app.DetectorPanel, 'numeric');
            app.PixelWidthField.Limits = [1 Inf];
            app.PixelWidthField.FontSize = 14;
            app.PixelWidthField.Position = [138 91 46 22];
            app.PixelWidthField.Value = 1;

            % Create PixelWidthUnits
            app.PixelWidthUnits = uidropdown(app.DetectorPanel);
            app.PixelWidthUnits.Items = {'mm', 'um'};
            app.PixelWidthUnits.Editable = 'on';
            app.PixelWidthUnits.ValueChangedFcn = createCallbackFcn(app, @UnitsValueChanged, true);
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
            app.DetectorShapeDropDown.FontSize = 14;
            app.DetectorShapeDropDown.Position = [139 129 110 22];
            app.DetectorShapeDropDown.Value = 'Flat';

            % Create PhantomPanel
            app.PhantomPanel = uipanel(app.RunTab);
            app.PhantomPanel.Title = 'Phantom';
            app.PhantomPanel.Visible = 'off';
            app.PhantomPanel.FontSize = 18;
            app.PhantomPanel.Position = [581 412 277 160];

            % Create PhantomListBoxLabel
            app.PhantomListBoxLabel = uilabel(app.PhantomPanel);
            app.PhantomListBoxLabel.HorizontalAlignment = 'right';
            app.PhantomListBoxLabel.FontSize = 14;
            app.PhantomListBoxLabel.Position = [19 101 61 22];
            app.PhantomListBoxLabel.Text = 'Phantom';

            % Create PhantomListBox
            app.PhantomListBox = uilistbox(app.PhantomPanel);
            app.PhantomListBox.Items = {'Example 1', 'Example 2'};
            app.PhantomListBox.ItemsData = {'Example 1', 'Example 2'};
            app.PhantomListBox.FontSize = 14;
            app.PhantomListBox.Position = [95 51 158 74];
            app.PhantomListBox.Value = 'Example 1';

            % Create PhantomLoadButton
            app.PhantomLoadButton = uibutton(app.PhantomPanel, 'push');
            app.PhantomLoadButton.ButtonPushedFcn = createCallbackFcn(app, @PhantomLoadButtonPushed, true);
            app.PhantomLoadButton.FontSize = 14;
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
            app.VoxelSizeEditField.Limits = [1 Inf];
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
            app.SourceTypeDropDown.FontSize = 14;
            app.SourceTypeDropDown.Position = [107 25 150 22];
            app.SourceTypeDropDown.Value = 'Parallel Beam';

            % Create Source1DropDownLabel
            app.Source1DropDownLabel = uilabel(app.SourcePanel);
            app.Source1DropDownLabel.HorizontalAlignment = 'right';
            app.Source1DropDownLabel.FontSize = 14;
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

            % Create RaysImage
            app.RaysImage = uiimage(app.ImagePanel);
            app.RaysImage.ImageClickedFcn = createCallbackFcn(app, @ToggleSourcePanelVisibility, true);
            app.RaysImage.Position = [72 210 464 416];
            app.RaysImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'parallel_rays.svg');

            % Create RotationImage
            app.RotationImage = uiimage(app.ImagePanel);
            app.RotationImage.ImageClickedFcn = createCallbackFcn(app, @RotationImageClicked, true);
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
            app.DistToDetectorField.Limits = [1 Inf];
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
            app.SourceImage.Position = [254 633 100 100];
            app.SourceImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'source.svg');

            % Create WireImage
            app.WireImage = uiimage(app.ImagePanel);
            app.WireImage.ImageClickedFcn = createCallbackFcn(app, @ToggleReconstructionPanelVisibility, true);
            app.WireImage.Position = [322 76 100 109];
            app.WireImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'wire.svg');

            % Create PCImage
            app.PCImage = uiimage(app.ImagePanel);
            app.PCImage.ImageClickedFcn = createCallbackFcn(app, @ToggleReconstructionPanelVisibility, true);
            app.PCImage.Position = [405 10 169 157];
            app.PCImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'PC.svg');

            % Create DetectorArrayImage
            app.DetectorArrayImage = uiimage(app.ImagePanel);
            app.DetectorArrayImage.ImageClickedFcn = createCallbackFcn(app, @ToggleDetectorPanelVisibility, true);
            app.DetectorArrayImage.Position = [61 140 502 149];
            app.DetectorArrayImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'flat_detector.svg');

            % Create DistToDetectorLine
            app.DistToDetectorLine = uiimage(app.ImagePanel);
            app.DistToDetectorLine.ImageClickedFcn = createCallbackFcn(app, @DistToDetectorLineImageClicked, true);
            app.DistToDetectorLine.Position = [-17 185 100 449];
            app.DistToDetectorLine.ImageSource = fullfile(pathToMLAPP, 'graphics', 'distance.svg');

            % Create RunButton
            app.RunButton = uibutton(app.ImagePanel, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.Icon = fullfile(pathToMLAPP, 'Play.png');
            app.RunButton.FontSize = 36;
            app.RunButton.Position = [402 608 158 58];
            app.RunButton.Text = 'Run';

            % Create NumberofRotationsEditField
            app.NumberofRotationsEditField = uieditfield(app.ImagePanel, 'numeric');
            app.NumberofRotationsEditField.Limits = [1 Inf];
            app.NumberofRotationsEditField.RoundFractionalValues = 'on';
            app.NumberofRotationsEditField.FontSize = 14;
            app.NumberofRotationsEditField.Position = [218 660 50 22];
            app.NumberofRotationsEditField.Value = 180;

            % Create ScatterImage
            app.ScatterImage = uiimage(app.ImagePanel);
            app.ScatterImage.ImageClickedFcn = createCallbackFcn(app, @ToggleScatterPanelVisibility, true);
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
            app.ScatterFactorSpinner.Position = [172 21 56 22];
            app.ScatterFactorSpinner.Value = 1;

            % Create NumberofRotationsLabel
            app.NumberofRotationsLabel = uilabel(app.ImagePanel);
            app.NumberofRotationsLabel.FontSize = 14;
            app.NumberofRotationsLabel.Position = [87 660 133 22];
            app.NumberofRotationsLabel.Text = 'Number of Rotations';

            % Create PhantomImage
            app.PhantomImage = uiimage(app.ImagePanel);
            app.PhantomImage.ImageClickedFcn = createCallbackFcn(app, @TogglePhantomPanelVisibility, true);
            app.PhantomImage.Position = [252 342 104 174];
            app.PhantomImage.ImageSource = fullfile(pathToMLAPP, 'graphics', 'SheppLogan_Phantom.svg');

            % Create SourceTab
            app.SourceTab = uitab(app.TabGroup);
            app.SourceTab.Title = 'Source';

            % Create PhantomTab
            app.PhantomTab = uitab(app.TabGroup);
            app.PhantomTab.Title = 'Phantom';

            % Create DetectorTab
            app.DetectorTab = uitab(app.TabGroup);
            app.DetectorTab.Title = 'Detector';

            % Create MovementPanel
            app.MovementPanel = uipanel(app.DetectorTab);
            app.MovementPanel.Title = 'Movement';
            app.MovementPanel.Position = [0 49 295 695];

            % Create PixelArrayPanel
            app.PixelArrayPanel = uipanel(app.DetectorTab);
            app.PixelArrayPanel.Title = 'Pixel Array';
            app.PixelArrayPanel.Position = [294 49 345 695];

            % Create SensorsPanel
            app.SensorsPanel = uipanel(app.DetectorTab);
            app.SensorsPanel.Title = 'Sensors';
            app.SensorsPanel.Position = [638 49 321 695];

            % Create RunContextMenu
            app.RunContextMenu = uicontextmenu(app.UIFigure);

            % Create LoadStateInContextMenu
            app.LoadStateInContextMenu = uimenu(app.RunContextMenu);
            app.LoadStateInContextMenu.Text = 'Load State';

            % Create SaveStateInContextMenu
            app.SaveStateInContextMenu = uimenu(app.RunContextMenu);
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
            app.RotationImage.ContextMenu = app.DetectorContextMenu;
            app.DetectorArrayImage.ContextMenu = app.DetectorContextMenu;
            app.DistToDetectorLine.ContextMenu = app.DetectorContextMenu;

            % Create PhantomContextMenu
            app.PhantomContextMenu = uicontextmenu(app.UIFigure);

            % Create LoadPhantomMenu
            app.LoadPhantomMenu = uimenu(app.PhantomContextMenu);
            app.LoadPhantomMenu.MenuSelectedFcn = createCallbackFcn(app, @PhantomLoadButtonPushed, true);
            app.LoadPhantomMenu.Text = 'Load Phantom';

            % Create PhantomHelpMenu_run
            app.PhantomHelpMenu_run = uimenu(app.PhantomContextMenu);
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

            % Create LoadPhantomInContextMenu
            app.LoadPhantomInContextMenu = uimenu(app.SourceContextMenu);
            app.LoadPhantomInContextMenu.MenuSelectedFcn = createCallbackFcn(app, @SourceLoadButtonPushed, true);
            app.LoadPhantomInContextMenu.Text = 'Load Source';

            % Create SourceHelpMenu_run
            app.SourceHelpMenu_run = uimenu(app.SourceContextMenu);
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

            % Create ReconSaveImageasMenu
            app.ReconSaveImageasMenu = uimenu(app.ReconImageContextMenu);
            app.ReconSaveImageasMenu.MenuSelectedFcn = createCallbackFcn(app, @ReconSaveImageasMenuSelected, true);
            app.ReconSaveImageasMenu.Text = 'Save Image as';

            % Create ReconOpeninNewWindowMenu
            app.ReconOpeninNewWindowMenu = uimenu(app.ReconImageContextMenu);
            app.ReconOpeninNewWindowMenu.MenuSelectedFcn = createCallbackFcn(app, @ReconOpeninNewWindowMenuSelected, true);
            app.ReconOpeninNewWindowMenu.Text = 'Open in New Window';

            % Create ReconImageHelpMenu
            app.ReconImageHelpMenu = uimenu(app.ReconImageContextMenu);
            app.ReconImageHelpMenu.Text = 'Help';
            
            % Assign app.ReconImageContextMenu
            app.ReconstructionImage.ContextMenu = app.ReconImageContextMenu;

            % Create SinogramImageContextMenu
            app.SinogramImageContextMenu = uicontextmenu(app.UIFigure);

            % Create SinogramSaveImageasMenu
            app.SinogramSaveImageasMenu = uimenu(app.SinogramImageContextMenu);
            app.SinogramSaveImageasMenu.MenuSelectedFcn = createCallbackFcn(app, @SinogramSaveImageasMenuSelected, true);
            app.SinogramSaveImageasMenu.Text = 'Save Image as';

            % Create SinogramOpeninNewWindowMenu
            app.SinogramOpeninNewWindowMenu = uimenu(app.SinogramImageContextMenu);
            app.SinogramOpeninNewWindowMenu.MenuSelectedFcn = createCallbackFcn(app, @SinogramOpeninNewWindowMenuSelected, true);
            app.SinogramOpeninNewWindowMenu.Text = 'Open in New Window';

            % Create SinogramImageHelpMenu
            app.SinogramImageHelpMenu = uimenu(app.SinogramImageContextMenu);
            app.SinogramImageHelpMenu.Text = 'Help';
            
            % Assign app.SinogramImageContextMenu
            app.SinogramImage.ContextMenu = app.SinogramImageContextMenu;

            % Create ReconstructionContextMenu
            app.ReconstructionContextMenu = uicontextmenu(app.UIFigure);

            % Create ReconstructionHelpMenu
            app.ReconstructionHelpMenu = uimenu(app.ReconstructionContextMenu);
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

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

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