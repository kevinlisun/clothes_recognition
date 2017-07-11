function [ newRangeMap, shiftZ ] = ShiftRangeMap( rangeMap, tableCorners, mode )

    
    [ XI, YI ] = meshgrid( 1:size(rangeMap,2), 1:size(rangeMap,1) );
    
    tablePlane = fit( tableCorners(:,1:2), tableCorners(:,3), 'poly11', 'Robust', 'LAR' );

    ppz = predint( tablePlane, [reshape(XI,[size(XI,1)*size(XI,2),1]), reshape(YI,[size(YI,1)*size(YI,2),1])] );
    ppz = mean(ppz,2);
    shiftZ = reshape( ppz, [size(rangeMap,1),size(rangeMap,2)] );
    shiftZ(isnan(rangeMap)) = nan;
    
    newRangeMap = shiftZ - rangeMap;