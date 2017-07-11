function [ ridgeMap ] = HierarchicalRidgeDetection( rangeMap, para )   
    
    nLayer = para.nLayer;
    sigma_init = para.sigma_init;
    mode = para.mode;
    threshold = para.threshold;

    flag = false;
    rangeMap = - rangeMap;
    [L sigma] = Construct_Regular_Gaussian_Pyramids( rangeMap, nLayer, sigma_init, mode);
    
    for i = 1:nLayer
        rangeMapi = L{i};
        
        %% compute H,K,k1,k2,S
        [fx,fy] = gradient(rangeMapi);
        [fxx, fxy] = gradient(fx);
        [fyx, fyy] = gradient(fy);
    
        H = ( (1+fy.^2).*fxx + (1+fx.^2).*fyy - 2.*fx.*fy.*fxy ) ./ ( 2*((sqrt(ones(size(fx))+fx.^2+fy.^2)).^3) );
        K = ( fxx.*fyy - fxy.^2 ) ./ ( ( ones(size(fx)) + fx.^2 + fy.^2 ).^2 );
    
        k1 = H + sqrt(H.^2.-K);
        k2 = H - sqrt(H.^2.-K);
        
% %         figure('name','layer i')
% %         hist(reshape(k1,[1 size(k1,1)*size(k1,2)]), 100)

        ridgeMapi = k1 >= threshold(i);
        
        if flag == true
            figure('name','layer i image')
            imagesc(ridgeMapi)
            colormap(gray)
        end
        
        ridgeMapi = imresize(ridgeMapi,size(rangeMap));
        ridgeMap(:,:,i) = ridgeMapi;
        
        if flag == true
            figure('name',['ridgeMap ',num2str(i)])
            imagesc(ridgeMapi);
            colormap(gray);
        end
        
    end
    
    ridgeMap  = sum(ridgeMap,3);
    ridgeMap = ridgeMap >= 1;