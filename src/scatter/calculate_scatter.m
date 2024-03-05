function [ray_start, ray_dir, mu, nrj, num_scatter] = calculate_scatter (n_mfp, ls, idxs, ray_start,...
    ray_dir, ray_len, nrj, prev_mu, num_scatter, mu_arr, mfp_arr, voxels, ray_tracing)

   % If there are no intersections, exit
   if isempty(ls); mu = prev_mu; return; end
   
   if  num_scatter == 0; mu = 0;
   else                ; mu = prev_mu;
   end

   % Get the mean free path of the first intersection
   mfps = voxels.get_saved_mfp(idxs, mfp_arr);
   
   % Check if the ray scatters at all
   ray_nmfp = n_mfp - cumsum(ls ./ mfps);
   check_nmfp = ray_nmfp < 0;
   
   if any(check_nmfp) % If the ray scatters
       % Get the index of the scatter event
       i = find(check_nmfp, 1, "first");
       
       % Calculate the mu of the ray until the end of the current voxel
       mu_to_scatter = voxels.get_saved_mu(idxs(:, 1:i), mu_arr);
       mu = mu + sum(ls(1:i) .* mu_to_scatter) + ...
           (ray_nmfp(i) * mfps(i)) * mu_to_scatter(i); % Remove the mu of the current voxel up to the scatter event

       % Get the new direction and energy of the ray, and update the start point
       ray_start = ray_start + (sum(ls(1:i)) + ray_nmfp(i) * mfps(i)) .* ray_dir;
       [ray_dir, nrj] = compton_scatter(ray_dir, nrj);
       
       % Create a new ray with the new direction, energy, and start point
       [ls, idxs] = ray_tracing(ray_start, ray_dir * ray_len, ...
           voxels.array_position, voxels.dimensions, voxels.num_planes);

       mu_arr = voxels.get_mu_arr(nrj);
       mfp_arr = voxels.get_mfp_arr(nrj);
       
       % Now repeat the process for the new ray
       [ray_start, ray_dir, mu, nrj, num_scatter] = calculate_scatter(-log(rand), ls, idxs, ...
           ray_start, ray_dir, ray_len, nrj, mu, num_scatter + 1, mu_arr, mfp_arr, voxels, ray_tracing);
   else
       mu = mu + sum(ls .* voxels.get_saved_mu(idxs, mu_arr));  % This case only occurs if the ray does not scatter
   end
end