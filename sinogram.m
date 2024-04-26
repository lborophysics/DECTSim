function [R, xp] = sinogram(P, theta)
    [R, xp] =  radon(P,theta);
%    disp(['numer of detectors is ', size(R, 1)]);
    figure, hold on;
    imagesc(R) %,[],'Xdata',theta,'Ydata',xp,'InitialMagnification','fit')
    colormap gray;
  %  title('Sinogram of Shepp-Logan phantom');
    title('Sinogram');
    xlabel('\theta (degrees)');
    ylabel('x''');
    axis tight;
    %colormap(gca,hot),
    
   % colorbar;
    hold off;
    
end
