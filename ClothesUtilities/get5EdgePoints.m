function [ grasp2D ] = get5EdgePoints( clothes, scale )

    grasp2D = zeros(5,2);
    
    [ Y X ] = find(clothes==1);
    
    meanX = round(mean(X));
    meanY = round(mean(Y));
    
    tmp_inx = find(Y>meanY-3&Y<meanY+3);
    tmpX = X(tmp_inx);
    
    [junk b] = min(tmpX); % most left
    
    grasp2D(1,:) = [ X(tmp_inx(b(1))); Y(tmp_inx(b(1))) ];
    
    [junk b] = max(tmpX); % most right
    
    grasp2D(2,:) = [ X(tmp_inx(b(1))); Y(tmp_inx(b(1))) ];
    
    tmp = Y-X;
    
    [junk b] = max(tmp); % left low
    
    grasp2D(3,:) = [ X(b(1)); Y(b(1)) ];
    
    tmp = Y+X; % right low
    
    [junk b] = max(tmp); % left low
    
    grasp2D(4,:) = [ X(b(1)); Y(b(1)) ];
    
    [junk b] = max(Y); % low
    
    grasp2D(5,:) = [ X(b(1)); Y(b(1)) ];
    
    grasp2D = grasp2D./scale;