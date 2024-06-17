function I = reconstruction1(R, theta, phantom_res) %, interp, filter, frequencyScaling, outputSize)
    
    %inverseradon
    I = iradon(R, theta, 'linear', phantom_res);
    I2 = iradon(R, theta,'linear', 'None', phantom_res);
  %  figure, imagesc(I), colormap gray;colorbar;
  %  title('Shepp-Logan Reconstruction')
  %  axis tight;
  %  axis equal;
    figure, imshow(I,[]), title('Reconstruction: Filtered');
    
    figure, imshow(I2,[]), title('Reconstruction: Unfiltered');
    
end
