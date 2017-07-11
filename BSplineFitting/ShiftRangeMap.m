function [ newRangeMap ] = ShiftRangeMap( rangeMap )


    [ px py pz ] = prepareSurfaceData( 1:size(rangeMap,2), 1:size(rangeMap,1), rangeMap );

    k = min(100000,0.01*length(px));
    samples_index = randsample(length(px),k);
    sampleX = px(samples_index);
    sampleY = py(samples_index);
    sampleZ = pz(samples_index);
    
    center = [ round(sum(px)/length(px)), round(sum(py)/length(py)) ];
    pView = [ center(1), center(2), rangeMap(center(2),center(1))*2 ];
    %pCenter = [ center(1), center(2), rangeMap(center(2),center(1)) ];
    pCenter = [ 0 0 0 ];

    samples = [ sampleX, sampleY, sampleZ ];
    covMat = cov( samples );
    [ V, D ] = eig( covMat );
    eigValue = diag( D );
    [ a b ] =min( eigValue );
    orien_normal = V(:,b)';
    orien_normal = orien_normal./sqrt(sum(orien_normal.^2));
    
    if dot(orien_normal,(pView-pCenter)) < 0
        orien_normal = -orien_normal;
    end
    
    x1 = pCenter(1);
    y1 = pCenter(2);
    z1 = pCenter(3);
    
    a  = orien_normal(1);
    b = orien_normal(2);
    c = orien_normal(3);
    
    [ XI, YI ] = meshgrid( 1:size(rangeMap,2), 1:size(rangeMap,1) );
    
    %shiftZ = (a*x1+b*y1+c*z1-a*XI-b*YI)/c;
    clothPlane = fit( [sampleX, sampleY], sampleZ, 'poly23', 'Robust', 'LAR' );
    ppz = predint( clothPlane, [reshape(XI,[size(XI,1)*size(XI,2),1]), reshape(YI,[size(YI,1)*size(YI,2),1])] );
    ppz = mean(ppz,2);
    shiftZ = reshape( ppz, [size(rangeMap,1),size(rangeMap,2)] );
    shiftZ(isnan(rangeMap)) = nan;
    shiftZ = shiftZ - mean(pz);
    
    newRangeMap = rangeMap - shiftZ;
    
    