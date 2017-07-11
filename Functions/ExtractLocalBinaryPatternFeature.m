function [ lbp_descriptors ] = ExtractLocalBinaryPatternFeature( model, garment_mask, para )

% %     step = para.sampling_step;
% %     
% %     garment2 = imresize(garment,1/step); % garment2 is the resized garment mask
% %     garment2(garment2>0) = 1;
% %     [Y X] = find(garment2==1);
% %     X = X*step-0.5*step;
% %     Y = Y*step-0.5*step;
% %     
% %     % create LBP histogram descriptors
% %     cellSize = para.cellSize;
% % 
% %         
% % 
% %     lbp_descriptors = VL_LBP( patch, cellSize );

rangeMap = model.rangeMap;
% % fittedSurface = model.fittedSurface;
% % surfaceNoise = rangeMap - fittedSurface;
%% compute the texture feature (Local Binary Descriptor)
cellSize = para.cellSize;
layerNum = para.layerNum;

rangeMap = single(rangeMap);

lbp_descriptors = [];
for i = 0:layerNum-1
    cellSizei =round( cellSize*(0.5)^(i));
    
    gaussPyramid = vision.Pyramid('PyramidLevel', i);
    rangeMapi = step(gaussPyramid, rangeMap);
    
    lbp = vl_lbp( rangeMapi, cellSizei );
    
    garment_mask = imresize(garment_mask,[size(lbp,1),size(lbp,2)],'nearest');
    lbp_descriptorsi = reshape(lbp,[size(lbp,1)*size(lbp,2) size(lbp,3)]);
    lbp_descriptorsi(garment_mask(:)==0,:) = [];
    lbp_descriptorsi = double(lbp_descriptorsi);
    
% % %     lbp_descriptors = [ lbp_descriptors, lbp_descriptorsi ];
    lbp_descriptors(:,:,i+1) =  lbp_descriptorsi;
end

lbp_descriptors = mean(lbp_descriptors,3);

% % lbp_descriptors1 = max(lbp_descriptors,[],3);
% % lbp_descriptors2 = min(lbp_descriptors,[],3);
% % 
% % lbp_descriptors = [ lbp_descriptors1, lbp_descriptors2 ];

