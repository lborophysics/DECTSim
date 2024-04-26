%calculate 1d projections along the xaxis and yaxis


function [x_proj_vec, y_proj_vec] = oneD_xy_proj(P)
    
    %note: vectorise these for loops!!
    
    %1D projection along x-axis:
    x_proj_vec = zeros(size(P,1),1);
    for row = 1:size(P,1)
        x_proj = sum(P(row,:));
        x_proj_vec(row,1) = x_proj;
    end

    
    %1D projection along y-axis:
    y_proj_vec = zeros(size(P,2),1);
    for col = 1:size(P,2)
        y_proj = sum(P(:,col));
        y_proj_vec(col,1) = y_proj;
    end
    
    %Generate plots:
    %plot 1
    figure;
    tiledlayout(1,2);
    hold on; 
    
    % Tile 1
    nexttile
    plot(x_proj_vec), camroll(-90), title('1D projection along x-axis'), xlabel('lambda'), ylabel('y');
    hold on;
    
    %Tile 2
    nexttile
    imshow(P)
    hold off;
    
    %plot 2 %Note:fix layout and axis orientation
    figure;
    tiledlayout(2,1);
    hold on;
    
    %Tile 2
    nexttile
    plot(y_proj_vec), title('1D projection along y-axis'), xlabel('lambda'), ylabel('y');
    hold on;
    
    %Tile 1
    nexttile
    imshow(P)
    hold off;
    
   

end
