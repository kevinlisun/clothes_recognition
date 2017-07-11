function [ Descriptors ] = ExtractLocalFeatures( model, Para, flag )

rangeMap = model.rangeMap;
fittedSurface = model.fittedSurface;
ridge = model.ridge;
contour = model.contour;
mask = model.mask;

%% extract B-Spline patch feature
% fit the surface using ploynomail 3-order BSpline surface fitting
if Para.local.bsp
    para.knotVec = [ 0 0 0 0 1 2 2 2 2 ];

    if strcmp(Para.sensor, 'RH')
        para.PatchSize = [ 35,35 ];
    elseif strcmp(Para.sensor, 'RH_fast')
        para.PatchSize = [ 21,21 ];
    elseif strcmp(Para.sensor, 'kinect')
        para.PatchSize = [ 21,21 ];
    end

    para.sampling_rate = 0.5;
    
    [ bsp_descriptors ] = ExtractBSplinePatchFeature( rangeMap, ridge, para );
    clear para;
end
%%

%% extract FINDDD feature
if Para.local.finddd
    
    para.s = [4, 4];
    para.o = 13;
    
    if strcmp(Para.sensor, 'RH')
        para.PatchSize = [ 85,85 ];
    elseif strcmp(Para.sensor, 'RH_fast')
        para.PatchSize = [ 43,43 ];
    elseif strcmp(Para.sensor, 'kinect')
        para.PatchSize = [ 43,43 ];
    end

    para.sampling_rate = 0.1;
    
    finddd_file = './FINDDD/finddd_para.mat';
    if exist(finddd_file)
        load(finddd_file);
    else
        [ bin_center ] = caculateBinCenters(para);
    end
    para.bin_center = bin_center;
    
    [ finddd_descriptors ] = ExtractFINDDDFeature( fittedSurface, mask, para );
    clear para    
    
end
%%

%% extract the LBP feature
if Para.local.lbp
    para.layerNum = 3;
    para.cellSize = 32;
    
    [ lbp_descriptors ] = ExtractLocalBinaryPatternFeature( model, mask==2, para );
end
%%

%% extract dense local DLCM feature
if Para.local.dlcm
    para.layerNum = 1;
    para.cellSize = 32;
    para.binlimits = [ -2 2 ];
    para.nlevels = 10;
    para.stepSize = 16;
    [ dlcm_descriptors ] = ExtractLocalDLCMFeature( model, mask==2, para );
end
%% extract the Shape Context feature

if Para.local.sc
    para.mean_dist = 100;
    para.nbins_theta = 16;
    para.nbins_r = 5;
    para.r_inner = 0.1;
    para.r_outer = 1;
    para.sampling_rate = 0.5;
    
    [ sc_descriptors ] = ExtractShapeContextFeature( mask==2, para, flag );
end
%% extract dense SIFT feature
if Para.local.sift
    para.stepSize = 16;
    para.patchSize = 32;
    
    [ sift_descriptors ] = ExtractDenseSiftFeature( model, mask==2, para );
end
%%
if Para.local.bsp
    Descriptors.bsp = bsp_descriptors;
end
if Para.local.finddd
    Descriptors.finddd = finddd_descriptors;
end
if Para.local.lbp
    Descriptors.lbp = lbp_descriptors;
end
if Para.local.sc
    Descriptors.sc = sc_descriptors;
end
if Para.local.dlcm
    Descriptors.dlcm = dlcm_descriptors;
end
if Para.local.sift
    Descriptors.sift = sift_descriptors;
end
