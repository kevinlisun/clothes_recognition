function [L sigma] = Construct_Regular_Gaussian_Pyramids( img, num_level, sigma_init, mode)
        
       
    if mode == 1
        sigma_c = sigma_init*sqrt(3);
        rho = 2;
    elseif mode == 2
% %         rho = sqrt(2);
% %         sigma_c = sigma_init*sqrt(rho^2-1);
        rho = 1.5;
        sigma_c = sigma_init*sqrt(rho^2-1);
    end
    
    filter = fspecial('gaussian', [3,3], sigma_init);
    L0 = imfilter( img, filter );
    L = cell(1,1);
    L{1,1} = L0;
    sigma = sigma_init;
    
    for i = 1:num_level-1
        filter = fspecial('gaussian', [3,3], sigma_c );
        L_currentlevel = imresize(L{i,1}, 1/rho);
        L{i+1,1} = L_currentlevel; % for matlab 2013a or before, use L = [ L; mat2cell(L_currentlevel)]
        
        sigma_currentlevel = sqrt( sigma(i,1)^2 + sigma_c^2 )/rho;
        sigma = [ sigma; sigma_currentlevel ];
    end
      
        
        