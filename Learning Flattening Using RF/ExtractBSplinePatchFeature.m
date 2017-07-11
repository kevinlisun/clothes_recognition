function [ bsp_descriptors ] = ExtractBSplinePatchFeature( rangeMap, ridgeMap, para )


sampling_rate = para.sampling_rate;
patchSize = para.patchSize;
knotVec = para.knotVec;

[Y X] = find(ridgeMap==1);

seg = round(1/sampling_rate);
X = X(1:seg:length(X));
Y = Y(1:seg:length(Y));

% compute the base function at the begining
uSize = fix(patchSize(2)/2)*2+1; % patch height
wSize = fix(patchSize(1)/2)*2+1; % patch length
[ C ] = ComputeUniformOpenBSplineBaseFun( knotVec, wSize, uSize );
% create bspline patch descriptors
bsp_descriptors = zeros(length(X),25+2);

for i = 1:length(X)
    x = X(i);
    y = Y(i);
    [ patch ] = GetPatch( rangeMap, [y x], fix(patchSize(1)/2) );
    if size(patch,1)~=uSize || size(patch,2)~=wSize
        continue;
    end
    xi = 1:size(patch,2);
    yi = 1:size(patch,1);
    [ XI YI ] = meshgrid( xi, yi ); 
    Patch(:,:,1) = XI;
    Patch(:,:,2) = YI;
    Patch(:,:,3) = patch;       
    [ obj ] = FitPatch( Patch, knotVec, C );
    bsp_descriptori = obj.B(:,3)- sum(sum(patch(isnan(patch)==0)))/sum(sum(isnan(patch)==0));
    bsp_descriptors(i,:) = [ bsp_descriptori', x, y ];
end