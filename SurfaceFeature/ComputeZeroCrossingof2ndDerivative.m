function [ contour ] = ComputeZeroCrossingof2ndDerivative( rangeMap, para )

    if strcmp(para.sensor, 'RH')
        r = 10;
    elseif strcmp(para.sensor, 'kinect')
        r = 7;
    end

    [ rangeMap, mat_mean, mat_std ] = RangeNormalization( rangeMap );

    h=fspecial('laplacian', 0.2);
    
    h = imresize(h,r);
    lmap =imfilter( rangeMap, h,'conv');
    
    contour = cvZeroCross2_yl(lmap);
