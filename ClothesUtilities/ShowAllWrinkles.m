function ShowAllWrinkles( rangeMap, wrinkle, showNum, mintorNum )

    wrinkleMap = zeros( size(rangeMap) );
    p = cell(5,1);
    p{1} = '*r';
    p{2} = '+g';
    p{3} = '*y';
    p{4} = '+b';
    p{5} = '*r';
    p{6} = '+g';
    p{7} = '*y';
    p{8} = '+b';
    
    
    set(0,'Units','pixels');
    scnsize = get(0,'ScreenSize');
    fig5 = figure('name', 'fitted wrinkles on fitted range surface');
    position = get(fig5,'Position');
    outerpos = get(fig5,'OuterPosition');
    borders = outerpos - position;
    
    edge = -borders(1)/3;
    
    if mintorNum == 2
        pos5 = [edge+scnsize(3)/3/2,...
            0,...
            scnsize(3)/3/2 - edge,...
            scnsize(4)/2];
    else
        pos5 = [edge+scnsize(3)/3,...
            0,...
            scnsize(3)/3 - edge,...
            scnsize(4)/2];
    end
    set(fig5,'OuterPosition',pos5)
    
    surf(rangeMap);
    w = size(rangeMap,2);
    h = size(rangeMap,1);
    axis([ 0+0.2*w 0.8*w 0+0.2*h 0.8*h mean(rangeMap(~isnan(rangeMap)))-150 mean(rangeMap(~isnan(rangeMap)))+250])

    view(2)
    camlight right;
    lighting phong;
    shading interp;
    hold on;
    
    for i = 1:showNum
        cX = wrinkle(i).fittedPoints(:,1);
        cY = wrinkle(i).fittedPoints(:,2);
        cZ = diag(rangeMap(cY,cX));
        plot3( cX, cY, cZ, p{i});
        
        hold on;
    end
    
    colormap jet
    
        set(gca, 'XDir', 'reverse');
        pause(0.1)