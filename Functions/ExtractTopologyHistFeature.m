function [ topo_descriptors ] = ExtractTopologyHistFeature( rangeMap, ridge, contour, para )


sampling_rate = para.sampling_rate;
patchSize = para.patchSize;

[Y X] = find(ridge==1);

seg = round(1/sampling_rate);
X = X(1:seg:length(X));
Y = Y(1:seg:length(Y));


% create topology histogram descriptors
bins = para.bins;
topo_descriptors = zeros(length(X),length(bins));

for i = 1:length(X)
    x = X(i);
    y = Y(i);
    
    [ ridgei ] = GetPatch( ridge, [y x], fix(patchSize(1)/2) );
    [ contouri ] = GetPatch( contour, [y x], fix(patchSize(1)/2) );
    
    [ topo_descriptors ] = ComputeTopoHist( ridgei, contouri, bins );
    topo_descriptors(i,:) = [ topo_descriptors ];
end