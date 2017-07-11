function [ shape_index ] = Compute_shapeIndex( rangeMap )


   %% compute H,K,k1,k2,S
%     [fx,fy] = imgradientxy(rangeMap);
%     [fxx, fxy] = imgradientxy(fx);
%     [fyx, fyy] = imgradientxy(fy);

    si = 3;
    sigma = 0.8;

    %% Compute Gaussian derivatives
    x=-si:1:si;
    y=-si:1:si;
    gaussx=-(x/(sigma*sigma)).*exp(-(x.*x+y.*y)/(2*sigma*sigma));
    gaussy=gaussx';
    fx = imfilter(rangeMap,gaussx,'conv');
    fy = imfilter(rangeMap,gaussy,'conv');
    
    fxx = imfilter(fx,gaussx,'conv');
    fyy = imfilter(fy,gaussy,'conv');
    fxy = imfilter(fx,gaussy,'conv');
    
        
    H = ( (1+fy.^2).*fxx + (1+fx.^2).*fyy - 2.*fx.*fy.*fxy ) ./ ( 2*((sqrt(ones(size(fx))+fx.^2+fy.^2)).^3) );
    K = ( fxx.*fyy - fxy.^2 ) ./ ( ( ones(size(fx)) + fx.^2 + fy.^2 ).^2 );
           
    k1 = H + sqrt(H.^2.-K);
    k2 = H - sqrt(H.^2.-K);
        
    s = (2/pi) .* ( atan((k2+k1)./(k2-k1)) );
    
    shape_index = zeros( size(rangeMap) );
    
    shape_index( -1<=s & s<-0.875 ) = 1;
    shape_index( -0.875<=s & s<-0.625 ) = 2;
    shape_index( -0.625<=s & s<-.0375 ) = 3;
    shape_index( -0.375<=s & s<-0.125 ) = 4;
    shape_index( -0.125<=s & s<0.125 ) = 5;
    shape_index( 0.125<=s & s<0.375 ) = 6;
    shape_index( 0.375<=s & s<0.625 ) = 7;
    shape_index( 0.625<=s & s<0.875 ) = 8;
    shape_index( 0.875<=s & s<=1 ) = 9;
    
