function ridgeMap_new = NonMaximumSppression( rangeImage, ridgeMap )

    [fx,fy] = imgradient(rangeImage);
    [fxx, fxy] = imgradient(fx);
    [fyx, fyy] = imgradient(fy);
    
    H = ( (1+fy.^2).*fxx + (1+fx.^2).*fyy - 2.*fx.*fy.*fxy ) ./ ( 2*((sqrt(ones(size(fx))+fx.^2+fy.^2)).^3) );
    K = ( fxx.*fyy - fxy.^2 ) ./ ( ( ones(size(fx)) + fx.^2 + fy.^2 ).^2 );
    
    kmax = H + sqrt(H.^2.-K);
    
    if sum(size(rangeImage)-size(ridgeMap)) ~= 0
        ridgeMap = imresize( ridgeMap, size(rangeImage) );
        ridgeMap( ridgeMap > 0 ) = 1;
    end

    % non-maximum suppression
    ridgeMagnitude = rangeImage;
    ridgeMagnitude(ridgeMap==0) = 0;
    
    [kx,ky] = gradient(kmax);
    theta = atan(ky./kx);
    
    angle = theta/pi*180;
    
    ridgeMap_new = zeros(size(ridgeMap));
    
    scaleFactor = 4;
    
    for y=1+scaleFactor:1:size(ridgeMap,1)-scaleFactor
        for x=1+scaleFactor:1:size(ridgeMap,2)-scaleFactor
            if(((angle(y,x)>=-22.5)&&(angle(y,x)<22.5))||((angle(y,x)<-157.5))||(angle(y,x)>157.5))
                if((ridgeMagnitude(y,x)>ridgeMagnitude(y,x+scaleFactor)) && (ridgeMagnitude(y,x)>ridgeMagnitude(y,x-scaleFactor)))
                    ridgeMap_new(y,x)=1;
                end
            end
            if(((angle(y,x)>=-112.5)&&(angle(y,x)<-67.5))||((angle(y,x)>=67.5)&&(angle(y,x)<112.5)))
                if((ridgeMagnitude(y,x)>ridgeMagnitude(y+scaleFactor,x)) && (ridgeMagnitude(y,x)>ridgeMagnitude(y-scaleFactor,x)))
                    ridgeMap_new(y,x)=1;
                end
            end
            if(((angle(y,x)>=-67.5)&&(angle(y,x)<-22.5))||((angle(y,x)>=112.5)&&(angle(y,x)<157.5)))
                if((ridgeMagnitude(y,x)>ridgeMagnitude(y-scaleFactor,x-scaleFactor)) && (ridgeMagnitude(y,x)>ridgeMagnitude(y+scaleFactor,x+scaleFactor)))
                    ridgeMap_new(y,x)=1;
                end
            end
            if(((angle(y,x)>=-157.5)&&(angle(y,x)<-112.5))||((angle(y,x)>=22.5)&&(angle(y,x)<67.5)))
                if((ridgeMagnitude(y,x)>ridgeMagnitude(y-scaleFactor,x+scaleFactor)) && (ridgeMagnitude(y,x)>ridgeMagnitude(y+scaleFactor,x-scaleFactor)))
                    ridgeMap_new(y,x)=1;
                end
            end
        end
    end
    
    ridgeMap_new = bwmorph(ridgeMap_new,'clean');
    %ridgeMap_new = bwmorph(ridgeMap_new,'thin');
    
    
    
    
    
    
    