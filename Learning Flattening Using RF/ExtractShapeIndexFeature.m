function [ si_descriptors ] = ExtractShapeIndexFeature( shapeIndex, ridgeMap, para )

sampling_rate = para.sampling_rate;
patchSize = para.patchSize;
knotVec = para.knotVec;

[Y X] = find(ridgeMap==1);

seg = round(1/sampling_rate);
X = X(1:seg:length(X));
Y = Y(1:seg:length(Y));

% create bspline patch descriptors
si_descriptors = zeros(length(X),9+2);

for i = 1:length(X)
    x = X(i);
    y = Y(i);
    [ patch ] = GetPatch( shapeIndex, [y x], fix(patchSize(1)/2) );
    
    si_descriptori = zeros(1,9);
    for j = 1:9
        si_descriptori(1,j) = sum(sum(patch==j))/(size(patch,1)*size(patch,2));
    end
    si_descriptors(i,:) = [ si_descriptori, x, y ];
end
