    clear all
    warning off
    close all
    clc

    imresizeScale = 0.1;
    
%% read data, prepare data, and apply nomalization
    load('~/Dropbox/Pile-Dataset/Masked_Clothes/rangeMap_01.mat');
    rangeMap = rangeMap*1000;
    rangeMap = imresize(double(rangeMap),imresizeScale);  
    
    [ rangeMap ] = ShiftRangeMap( rangeMap );

    m = size(rangeMap,1);
    n = size(rangeMap,2);
    
% %     [ patch ] = GetPatch( rangeMap, [250 250], 10 );
% %     xi = 1:21;
% %     yi = 1:21;
% %     [ XI YI ] = meshgrid( xi, yi ); 
% %     Patch(:,:,1) = XI;
% %     Patch(:,:,2) = YI;
% %     Patch(:,:,3) = patch;
% %     knotVec = [ 0 0 0 0 1 2 3 4 4 4 4  ];
% %     [ obj ] = FitPatch( Patch, knotVec )
% %     
% %     figure(1)
% %     surf(patch)
% %     camlight right;
% %     lighting phong;
% %     shading interp
% %     
% %     figure(2)
% %     surf(obj.patch);
% %     camlight right;
% %     lighting phong;
% %     shading interp
% %     hold on
% %     %plot3(obj.B(:,1),obj.B(:,2),obj.B(:,3),'b*');
    
    figure('name','orienginal range map');
    surf(rangeMap);
    axis([0 500 0 350 1200 1800])
    camlight right;
    lighting phong;
    shading interp
    
    knotVec = [ 0 0 0 0 1 2 3 4 5 5 5 5 ];
    patchSize = [ 25 25 ];
    mask = isnan( rangeMap );
    [ fittedRangeMap ] = BSplineSurfaceFitting( rangeMap, patchSize, knotVec, 30 );
    
    
% %     [ fit_obj ] = PiecewiseBSplineFitting( rangeMap, patchSize, knotVec );
% %     Points = fit_obj.points; 
% %     figure('name','surface from fitted point clouds');
% %     xi = 1:size(rangeMap,2);
% %     yi = 1:size(rangeMap,1);
% %     [ XI YI ] = meshgrid( xi, yi );
% %     fittedRangeMap = griddata( Points(:,1), Points(:,2), Points(:,3), XI, YI, 'cubic' );
% %     fittedRangeMap(isnan(rangeMap)) = NaN;
% %     surf(fittedRangeMap);
% %     axis([0 500 0 350 1200 1800])
% %     camlight right;
% %     lighting phong;
% %     shading interp
% %     
% %     fittedRangeMap = fit_obj.rangeMap;
    
    figure('name','fitted range map');
    surf(fittedRangeMap);
    axis([0 500 0 350 1200 1800])
    camlight right;
    lighting phong;
    shading interp

    
 