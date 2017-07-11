function [ dlcm_descriptors ] = ExtractLocalDLCMFeature( model, garment_mask, para )

rangeMap = model.rangeMap;
fittedSurface = model.fittedSurface;
surfaceNoise = rangeMap - fittedSurface;

%% compute the texture feature (Local Binary Descriptor)
cellSize = para.cellSize;
layerNum = para.layerNum;
nlevels = para.nlevels;
binlimits = para.binlimits;
stepSize = para.stepSize;
garment_mask = double(garment_mask);

dlcm_descriptors = [];

    
    %% compute Depthe-level Co-occurrence Matrix (DLCM) in grid
    
    mask = imresize(garment_mask,1/stepSize,'nearest');
    [Y X] = find(mask==1);
    X = X*stepSize - 0.5*stepSize;
    Y = Y*stepSize - 0.5*stepSize;
    
    dlcm_descriptors = zeros(length(X),(nlevels-2)*layerNum);
    
    for i = 1:length(X)
        x = X(i);
        y = Y(i);
        
        % get the square patch that size of (cellSize,cellSize)
        patch = getSquarePatch( surfaceNoise, [y x], [cellSize cellSize] );
        
        dlcm_descriptorsi = [];
        for j = 0:layerNum-1
            patchj = imresize(patch,0.5^(j));
            dlcm = graycomatrix(patchj,'GrayLimits', binlimits,'NumLevels',nlevels,'Offset',[0 1]);
            dlcm = dlcm(2:end-1,2:end-1);
            [U S V] = svd(dlcm);
            dlcm_descriptor = diag(S);
            [ dlcm_descriptor ] = l1norm( dlcm_descriptor(:)' );
            dlcm_descriptorsi = [ dlcm_descriptorsi, dlcm_descriptor ];
        end
        dlcm_descriptors(i,:) = dlcm_descriptorsi;
    end
    
    nanInx = sum(isnan(dlcm_descriptors),2);
    dlcm_descriptors(nanInx>0,:) = [];
    



