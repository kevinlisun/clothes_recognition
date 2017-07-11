function [ surface ] = ShowShapeIndex( rangeSurface, shape_index )

    shape_index(shape_index==0) = NaN;

    surface = 255*ones([size(shape_index),3]);
    
    surface(shape_index==1) = 0;   
    surface(shape_index==2) = 0;  
    surface(shape_index==3) = 0;  
    surface(shape_index==4) = 255;  
    surface(shape_index==5) = 0; 
    surface(shape_index==6) = 255; 
    surface(shape_index==7) = 255;  
    surface(shape_index==8) = 128; 
    surface(shape_index==9) = 64; 
    
    surface(:,:,4) = surface(:,:,1);
    surface(:,:,1) = [];
    
    surface(shape_index==1) = 128;
    surface(shape_index==2) = 0;
    surface(shape_index==3) = 128;
    surface(shape_index==4) = 0;
    surface(shape_index==5) = 0; 
    surface(shape_index==6) = 0; 
    surface(shape_index==7) = 255;
    surface(shape_index==8) = 64; 
    surface(shape_index==9) = 64; 
    
    surface(:,:,4) = surface(:,:,1);
    surface(:,:,1) = [];
    
    surface(shape_index==1) = 255;
    surface(shape_index==2) = 0;
    surface(shape_index==3) = 0;
    surface(shape_index==4) = 255;
    surface(shape_index==5) = 255;
    surface(shape_index==6) = 0;
    surface(shape_index==7) = 0;
    surface(shape_index==8) = 0;
    surface(shape_index==9) = 64;
    
    surface(:,:,4) = surface(:,:,1);
    surface(:,:,1) = [];
    
    
    
    surface = uint8(surface);
    
    
    subplot(2,2,2);
    surf( rangeSurface, shape_index );
    [ oy ox ]  = find(~isnan(rangeSurface));
    ox = mean(ox);
    oy = mean(oy);
    r = 0.4*size(rangeSurface,1);
    axis([ox - r, ox + r, oy - r, oy + r, min(rangeSurface(:)), max(rangeSurface(:))]);
    view(2)
    title('shape index on surface');
    color_bar(1,:) = [ 0,128,255 ];
    color_bar(2,:) = [ 0,0,0 ];
    color_bar(3,:) = [ 0,128,0 ];
    color_bar(4,:) = [ 255,0,128 ];
    color_bar(5,:) = [ 0,0,160 ];
    color_bar(6,:) = [ 255,0,0 ];
    color_bar(7,:) = [ 255,255,0 ];
    color_bar(8,:) = [ 128,64,0 ];
    color_bar(9,:) = [ 90,90,90 ];
    

    shape_uni = unique(shape_index);
    shape_uni(isnan(shape_uni)) = [];
    
    color_map = color_bar(shape_uni,:)./255;
    
    colormap(color_map);
    
    camlight right;
    lighting phong;
    shading interp
    
    
    
    