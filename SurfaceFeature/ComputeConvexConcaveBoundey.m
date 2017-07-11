function [ contour ] = ComputeConvexConcaveBoundey( shapeIndex )

    shapeIndex( shapeIndex <= 5 ) = -1;
    shapeIndex( shapeIndex >5 ) = 1;
    
    edge_up = shapeIndex + [ shapeIndex(2:end,:);shapeIndex(1,:) ];
    edge_up = edge_up == 0;
    
%     edge_down = shapeIndex+[ shapeIndex(end,:); shapeIndex(1:end-1,:) ];
%     edge_down = edge_down == 0;
    
    edge_left = shapeIndex +[ shapeIndex(:,2:end), shapeIndex(:,1) ];
    edge_left = edge_left==0;
    
%     edge_right = shapeIndex+[ shapeIndex(:,end), shapeIndex(:,1:end-1) ];
%     edge_right = edge_right==0;
    
    edges = edge_up+edge_left;
    contour = edges>0;
    

   
    
