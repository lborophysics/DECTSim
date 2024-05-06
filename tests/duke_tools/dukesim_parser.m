function [sinogram, params] = dukesim_parser(path_to_duke_out)
%DUKESIM_PARSER Given the path_to_duke_out of a DukeSim run, return the sinogram 
%   The path_to_duke_out is a parameter in the input file to DukeSim called MainDir
%   - currently only supports one MainDir
    
    % Get the folder name and the path 
    dirs = genpath(path_to_duke_out); % https://stackoverflow.com/questions/8748976/list-the-subfolders-in-a-folder-matlab-only-subfolders-not-files
    dir_list = strsplit(dirs,':');
    dir = dir_list{2}; % Assume there is only 1 folder in the MainDir
        
    % Read the ray tracing parameter file
    file_string = readlines(strcat(dir,'/rtcat_params.txt'));
    file_string = erase(file_string, " ");
    file_string = erase(file_string, "\t");
    if file_string{end} == ""; file_string = file_string(1:end-1); end % Remove empty line at end
    file_string = cellfun(@(x) strsplit(x, ':'), file_string, 'UniformOutput', false); % https://uk.mathworks.com/matlabcentral/answers/515836-how-do-i-split-cell-array-of-strings-by-using-a-character-delimiter
    file_string = horzcat(file_string{:});
    params = dictionary(file_string{:});

    % Read the sinogram file
    fileID = fopen(strcat(dir,".xcat"), "r");
    sinogram = fread(fileID, 'float32');  
    ny_pixels = str2double(params('scanner_Y_pixels'));
    nz_pixels = str2double(params('scanner_Z_pixels'));
    num_rotations = str2double(params("P"));
    sinogram = reshape(sinogram, [ny_pixels, nz_pixels, num_rotations]);
    fclose(fileID);
end

