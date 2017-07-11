function [ edges ] = Detect_Clothes_Conour( cloth )

    if max(cloth(:) == 255)
        cloth = cloth ./ 255;
    end

    edge_up = cloth+[ cloth(2:end,:); cloth(1,:) ];
    edge_up = edge_up==1;
    
    edge_down = cloth+[ cloth(end,:); cloth(1:end-1,:) ];
    edge_down = edge_down==1;
    
    edge_left = cloth+[ cloth(:,2:end), cloth(:,1) ];
    edge_left = edge_left==1;
    
    edge_right = cloth+[ cloth(:,end), cloth(:,1:end-1) ];
    edge_right = edge_right==1;
    
    edges = edge_up+edge_down+edge_left+edge_right;
    edges = edges>0;