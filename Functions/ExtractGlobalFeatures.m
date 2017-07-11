function [ Descriptors ] = ExtractGlobalFeatures( model, para, flag )

rangeMap = model.rangeMap;
fittedSurface = model.fittedSurface;
ridge = model.ridge;
contour = model.contour;
mask = model.mask;
shapeIndex = model.shapeIndex;


%% extract shape index histogram
if para.global.si
    
    shape_index = shapeIndex(:);
    shape_index(isnan(shape_index)) = [];
    
    si_descriptor = zeros(1,9);
    for j = 1:9
        si_descriptor(1,j) = sum(shape_index==j);
    end
    [ si_descriptor ] = l2norm( si_descriptor );
end

%% compute the topology feature
% the defalt bin setting is 1:1:100 pixel
if para.global.topo  
    if strcmp(para.sensor, 'RH')
        bins{1} = 1:5:50;
    elseif strcmp(para.sensor, 'RH_fast')
        bins{1} = 1:2.5:25;
    elseif strcmp(para.sensor, 'kinect')
        bins{1} = 1:2.5:25;
    end
   
    bins{2} = 1:5:50;
    [ topo_descriptor ] = ComputeTopoHist( rangeMap, ridge, contour, bins );
    [ topo_descriptor ] = l2norm( topo_descriptor );
end
%% compute the texture feature (Local Binary Descriptor)

if para.global.lbp
    surfaceNoise = rangeMap - fittedSurface;
    
    layerNum = 3;
    cellSize = 32;
    rangeMap = single(rangeMap);
    lbp_descriptor = [];
    
    for i = 0:layerNum-1
        cellSizei =round( cellSize*(0.5)^(i));
        
        gaussPyramid = vision.Pyramid('PyramidLevel', i);
        rangeMapi = step(gaussPyramid, rangeMap);
        
        lbp = vl_lbp( rangeMapi, cellSizei );
        garment_mask = mask==2;
        garment_mask = imresize(garment_mask,[size(lbp,1),size(lbp,2)],'nearest');
        lbp_descriptori = reshape(lbp,[size(lbp,1)*size(lbp,2) size(lbp,3)]);
        lbp_descriptori(garment_mask(:)==0,:) = [];
        lbp_descriptori = double(lbp_descriptori);
        lbp_descriptori = sum(lbp_descriptori,1);
        lbp_descriptori = lbp_descriptori;
        
        lbp_descriptor = [ lbp_descriptor, lbp_descriptori ];
    end
    
    % % lbp_descriptor = mean(lbp_descriptor, 1);
    % % [ lbp_descriptor ] = l2norm( lbp_descriptor );
end

%% compute Depthe-level Co-occurrence Matrix (DLCM)

if para.global.dlcm
    layerNum = 1;
    
    surfaceNoise = rangeMap - fittedSurface;
    dlcm_descriptor = [];
    
    for i = 0:layerNum-1
        gaussPyramid = vision.Pyramid('PyramidLevel', i);
        surfaceNoisei = step(gaussPyramid, surfaceNoise);
        
        dlcm = graycomatrix(surfaceNoisei,'GrayLimits',[-2 2],'NumLevels',10,'Offset',[0 1]);
        dlcm = dlcm(2:end-1,2:end-1);
        dlcm_descriptori = dlcm;
        % %     [U S V] = svd(dlcm);
        % %     dlcm_descriptori = diag(S);
        [ dlcm_descriptori ] = l1norm( dlcm_descriptori(:)' );
        dlcm_descriptor = [dlcm_descriptor, dlcm_descriptori];
    end
end

%% compute Image Moments

if para.global.imm
    para.s = [4,4];
    imm_descriptor = image_moments(rangeMap-nanmean(nanmean(rangeMap)), para);
end

%% compute clothes volumetic

if para.global.vol
    para.divided = 16;
    para.layers  = 16;
    para.rings   = 16;
    para.start_angle = 0;
    vol_descriptor = clothes_vol(rangeMap, mask==2, para);
end

%% output

%% feature setting

if para.global.si
    Descriptors.si = si_descriptor;
end

if para.global.lbp
   Descriptors.lbp = lbp_descriptor;
end

if para.global.topo
    Descriptors.topo = topo_descriptor;
end

if para.global.dlcm
    Descriptors.dlcm = dlcm_descriptor;
end

if para.global.imm
    Descriptors.imm = imm_descriptor;
end
if para.global.vol
    Descriptors.vol = vol_descriptor;
end

