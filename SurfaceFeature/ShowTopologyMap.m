function ShowTopologyMap( rangeMap, ridgeMap, contour )

    subplot(2,2,3);
    surf(rangeMap);
    [ oy ox ]  = find(~isnan(rangeMap));
    ox = mean(ox);
    oy = mean(oy);
    r = 0.4*size(rangeMap,1);
    axis([ox - r, ox + r, oy - r, oy + r, min(rangeMap(:)), max(rangeMap(:))]);
    view(2);
    camlight right;
    lighting phong;
    shading interp;
    title('topology on fitted cloth surface');

    hold on;
    ridgeMap = imresize(ridgeMap,size(rangeMap));
    ridgeMap( ridgeMap>0 ) = 1;
    
    [cX cY] = find( ridgeMap==1 );
    cZ = rangeMap(find(ridgeMap==1));
    plot3( cY, cX, cZ, '+r');
    
    hold on;
    
    [cX cY] = find( contour==1 );
    cZ = rangeMap(find(contour==1));
    plot3( cY, cX, cZ, '+g');
    
    colormap jet
    
    hold off

    pause(0.1)