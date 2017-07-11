    clear all
    warning off
    close all
    clc

    imresizeScale = 0.1;
    
%% read data, prepare data, and apply nomalization
    load('./img.mat');
    
    figure('name','orienginal range map');
    surf(img);
    axis([0 50 0 50 1400 1600])
    camlight right;
    lighting phong;
    shading interp
    
    knotVec = [ 0 0 0 0 1 1 1 1 ];
    patchSize = [ 25 25 ];
    
    patchNW = img(1:25,1:25);
    patchNE = img(1:25,26:50);
    patchSW = img(26:50,1:25);
    patchSE = img(26:50,26:50);
    xi = 1:25;
    yi = 1:25;
    [ XI YI ] = meshgrid( xi, yi );
    PatchNW(:,:,1) = XI;
    PatchNW(:,:,2) = YI;
    PatchNW(:,:,3) = patchNW;
    xi = 26:50;
    yi = 1:25;
    [ XI YI ] = meshgrid( xi, yi );
    PatchNE(:,:,1) = XI;
    PatchNE(:,:,2) = YI;
    PatchNE(:,:,3) = patchNE;
    xi = 1:25;
    yi = 26:50;
    [ XI YI ] = meshgrid( xi, yi );
    PatchSW(:,:,1) = XI;
    PatchSW(:,:,2) = YI;
    PatchSW(:,:,3) = patchSW;
    xi = 26:50;
    yi = 26:50;
    [ XI YI ] = meshgrid( xi, yi );
    PatchSE(:,:,1) = XI;
    PatchSE(:,:,2) = YI;
    PatchSE(:,:,3) = patchSE;
    %%
    
    %%
    figure('name','pure fitting');
    [ objNW ] = FitPatch( PatchNW, knotVec );
    plot3(objNW.D(:,1),objNW.D(:,2),objNW.D(:,3),'b+');
    hold on
    plot3(objNW.B(:,1),objNW.B(:,2),objNW.B(:,3),'g^','MarkerSize',10);
    hold on
    [ objNE ] = FitPatch( PatchNE, knotVec );
    plot3(objNE.D(:,1),objNE.D(:,2),objNE.D(:,3),'r+');
    hold on
    plot3(objNE.B(:,1),objNE.B(:,2),objNE.B(:,3),'y^','MarkerSize',10);
    hold on
    [ objSW ] = FitPatch( PatchSW, knotVec );
    plot3(objSW.D(:,1),objSW.D(:,2),objSW.D(:,3),'y+');
    hold on
    plot3(objSW.B(:,1),objSW.B(:,2),objSW.B(:,3),'r^','MarkerSize',10);
    hold on
    [ objSE ] = FitPatch( PatchSE, knotVec );
    plot3(objSE.D(:,1),objSE.D(:,2),objSE.D(:,3),'g+')
    hold on
    plot3(objSE.B(:,1),objSE.B(:,2),objSE.B(:,3),'b^','MarkerSize',10);
    %%
    
    %% achieve C0 continuity
    [ objNW objNE ] = Joint2HorizontalPatchesC0( objNW, objNE );
    % joint the South West and South East Patch
    [ objSW objSE ] = Joint2HorizontalPatchesC0( objSW, objSE );
    % joint the North West and South West Patch
    [ objNW objSW ] = Joint2VerticalPatchesC0( objNW, objSW );
     % joint the North East and South East Patch
    [ objNE objSE ] = Joint2VerticalPatchesC0( objNE, objSE );
    
    [ objNW objNE objSW objSE ] = Adjust4PatchesCenterC0( objNW, objNE, objSW, objSE );
    
    objNW.D = objNW.C * objNW.B;
    objNE.D = objNE.C * objNE.B;
    objSW.D = objSW.C * objSW.B;
    objSE.D = objSE.C * objSE.B;
    
    figure('name','achieving C0');
    plot3(objNW.D(:,1),objNW.D(:,2),objNW.D(:,3),'b+');
    hold on
    plot3(objNW.B(:,1),objNW.B(:,2),objNW.B(:,3),'g^','MarkerSize',10);
    hold on
    plot3(objNE.D(:,1),objNE.D(:,2),objNE.D(:,3),'r+');
    hold on
    plot3(objNE.B(:,1),objNE.B(:,2),objNE.B(:,3),'y^','MarkerSize',10);
    hold on
    plot3(objSW.D(:,1),objSW.D(:,2),objSW.D(:,3),'y+');
    hold on
    plot3(objSW.B(:,1),objSW.B(:,2),objSW.B(:,3),'r^','MarkerSize',10);
    hold on
    plot3(objSE.D(:,1),objSE.D(:,2),objSE.D(:,3),'g+')
    hold on
    plot3(objSE.B(:,1),objSE.B(:,2),objSE.B(:,3),'b^','MarkerSize',10);
        
%     depth_NW = reshape(objNW.D(:,3),[objNW.pnum_u,objNW.pnum_w]);
%     depth_NE = reshape(objNE.D(:,3),[objNE.pnum_u,objNE.pnum_w]);
%     depth_SW = reshape(objSW.D(:,3),[objSW.pnum_u,objSW.pnum_w]);
%     depth_SE = reshape(objSE.D(:,3),[objSE.pnum_u,objSE.pnum_w]);
%     fittedPatch = [ depth_NW,depth_NE;depth_SW,depth_SE; ];
%     
%     figure('name','fitted patch C0');
%     surf(fittedPatch);
%     axis([0 50 0 50 1400 1600])
%     camlight right;
%     lighting phong;
%     shading interp
    
    %%
    
    %% achieve C1 continuity
    figure('name','achieving C1')
    

    [ objNW objNE objSW objSE ] = Adjust4InteriorPoints( objNW, objNE, objSW, objSE );

    [ objNW objNE ] = Joint2HorizontalPatchesC1( objNW, objNE );
    % joint the South West and South East Patch
    [ objSW objSE ] = Joint2HorizontalPatchesC1( objSW, objSE );
    % joint the North West and South West Patch
    [ objNW objSW ] = Joint2VerticalPatchesC1( objNW, objSW );
     % joint the North East and South East Patch
    [ objNE objSE ] = Joint2VerticalPatchesC1( objNE, objSE );
    
    [ objNW objNE objSW objSE ] = Adjust4PatchesCenterC1( objNW, objNE, objSW, objSE );
 
    
      
    
    objNW.D = objNW.C * objNW.B;
    objNE.D = objNE.C * objNE.B;
    objSW.D = objSW.C * objSW.B;
    objSE.D = objSE.C * objSE.B;
    
    
    plot3(objNW.D(:,1),objNW.D(:,2),objNW.D(:,3),'b+');
    hold on
    plot3(objNW.B(:,1),objNW.B(:,2),objNW.B(:,3),'g^','MarkerSize',10);
    hold on
    plot3(objNE.D(:,1),objNE.D(:,2),objNE.D(:,3),'r+');
    hold on
    plot3(objNE.B(:,1),objNE.B(:,2),objNE.B(:,3),'y^','MarkerSize',10);
    hold on
    plot3(objSW.D(:,1),objSW.D(:,2),objSW.D(:,3),'y+');
    hold on
    plot3(objSW.B(:,1),objSW.B(:,2),objSW.B(:,3),'r^','MarkerSize',10);
    hold on
    plot3(objSE.D(:,1),objSE.D(:,2),objSE.D(:,3),'g+')
    hold on
    plot3(objSE.B(:,1),objSE.B(:,2),objSE.B(:,3),'b^','MarkerSize',10);
    hold on
    
    depth_NW = reshape(objNW.D(:,3),[objNW.pnum_u,objNW.pnum_w]);
    depth_NE = reshape(objNE.D(:,3),[objNE.pnum_u,objNE.pnum_w]);
    depth_SW = reshape(objSW.D(:,3),[objSW.pnum_u,objSW.pnum_w]);
    depth_SE = reshape(objSE.D(:,3),[objSE.pnum_u,objSE.pnum_w]);
    fittedPatch = [ depth_NW,depth_NE;depth_SW,depth_SE; ];
    
    figure('name','fitted patch C1');
    surf(fittedPatch);
    axis([0 50 0 50 1400 1600])
    camlight right;
    lighting phong;
    shading interp
    
    
