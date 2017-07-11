function [ bsp_descriptors ] = ExtractBSplinePatchFeature( rangeMap, ridgeMap, para )


sampling_rate = para.sampling_rate;
PatchSize = para.PatchSize;
knotVec = para.knotVec;
layerNum = size(PatchSize,1);

ridgeMap = imresize(ridgeMap,sampling_rate,'nearest');

[Y X] = find(ridgeMap==1);
scale = 1/sampling_rate;
Y = Y*scale-0.5*scale;
X = X*scale-0.5*scale;

for layeri=1:layerNum
    patchSize = PatchSize(layeri,:);
    % compute the base function at the begining
    uSize = fix(patchSize(2)/2)*2+1; % patch height
    wSize = fix(patchSize(1)/2)*2+1; % patch length
    [ C{layeri} ] = ComputeUniformOpenBSplineBaseFun( knotVec, wSize, uSize );
    % create bspline patch descriptors
    xi = 1:patchSize;
    yi = 1:patchSize;
    [ XI{layeri} YI{layeri} ] = meshgrid( xi, yi );
end

batchNum = fix(length(X)/12);
restNum = length(X) - 12*batchNum;

for i = 1:12
    pX{i} = X((i-1)*batchNum+1:i*batchNum);
    pY{i} = Y((i-1)*batchNum+1:i*batchNum);
end
for i = 1:restNum
    pX{i} = [ pX{i}; X(12*batchNum+i) ];
    pY{i} = [ pY{i}; Y(12*batchNum+i) ];
end
    
bsp_descriptors = cell(12,1);

for b = 1:12
    bsp_descriptors{b} = zeros(length(pX{b}),25*layerNum);
    
    for i = 1:length(pX{b})
        x = pX{b}(i);
        y = pY{b}(i);
        bsp_descriptor_alllayers = [];
        
        for layeri=1:layerNum
            patchSize = PatchSize(layeri,:);
            [ patch ] = GetPatch( rangeMap, [y x], fix(patchSize(1)/2) );
            
            uSize = fix(patchSize(2)/2)*2+1; % patch height
            wSize = fix(patchSize(1)/2)*2+1; % patch length
            
            if size(patch,1)~=uSize || size(patch,2)~=wSize
                layeri = 2;
                continue;
            end
            Patch = zeros(patchSize(1),patchSize(2),3);
            Patch(:,:,1) = XI{layeri};
            Patch(:,:,2) = YI{layeri};
            Patch(:,:,3) = patch;
            [ obj ] = FitPatch( Patch, knotVec, C{layeri} );
            bsp_descriptori = obj.B(:,3)- sum(sum(patch(isnan(patch)==0)))/sum(sum(isnan(patch)==0));
            bsp_descriptor_alllayers = [ bsp_descriptor_alllayers;bsp_descriptori ];
        end
        if ~isempty(bsp_descriptor_alllayers)
            bsp_descriptors{b}(i,:) =  bsp_descriptor_alllayers';
        end
    end
end

bsp_descriptors = cell2mat(bsp_descriptors);