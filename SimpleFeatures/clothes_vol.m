function [ vol_descriptor ] = clothes_vol(im, mask, para)

    im(~mask) = NaN;
    
    [Y X] = find(isnan(im) == 0);
    Z = im(find(isnan(im) == 0));
    
    X = X - mean(X);
    Y = Y - mean(Y);
    Z = Z - mean(Z);
    
    X = X(1:100:end);
    Y = Y(1:100:end);
    Z = Z(1:100:end);
    
    stdTol = 15;
    mesh = pointCloud2rawMesh([X Y Z],stdTol);
    
    inst{1}.v = mesh.vertices';
    
    vol_descriptor = BuildPtPyramid(inst, para);
    vol_descriptor = vol_descriptor{1}';