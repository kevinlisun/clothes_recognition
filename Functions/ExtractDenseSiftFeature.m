function [ sift_descriptors ] = ExtractDenseSiftFeature( model, garment_mask, para )



rangeMap = model.rangeMap;

%% compute the texture feature (Local Binary Descriptor)
patchSize = para.patchSize;
stepSize = para.stepSize;

rangeMap = single(rangeMap);

[pos, sift] = vl_dsift(rangeMap, 'size', patchSize,'step',stepSize);
pos = pos';
sift = double(sift');
inx = diag(garment_mask(pos(:,2),pos(:,1)));
sift_descriptors = sift(inx==1,:);

sift_descriptors(sum((sift_descriptors==0),2)==128,:) = [];







