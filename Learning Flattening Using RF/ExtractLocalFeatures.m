function [ bsp_descriptors si_descriptors ] = ExtractLocalFeatures( rangeMap, flag )

%% surface shape index analysis
para.knotVec = [ 0 0 0 0 1 2 2 2 2 ];
para.patchSize = [ 35 35 ];
para.ntimes = 10;
para.mask = rangeMap >= -356.5;

[ rangeMap ] = BSplineSurfaceFitting( rangeMap, para );
[ shapeIndex ] = Compute_shapeIndex( rangeMap );
if flag ==true
    [ shapeIndexIMG ] = ShowShapeIndex( rangeMap, shapeIndex );
end
clear para
%%

%% ridge detection
para.nLayer = 3;
para.sigma_init = 0.5;
para.mode = 2;
para.threshold = [0.1,0.2,0.3];

[ ridgeMap ] = HierarchicalRidgeDetection( rangeMap, para );
clear para
% non-maximum suppression
rangeImage = mapminmax( rangeMap, 0, 255 );
ridgeMap = NonMaximumSppression( rangeImage, ridgeMap );
%%

%% extract B-Spline patch feature
% fit the surface using ploynomail 3-order BSpline surface fitting
para.knotVec = [ 0 0 0 0 1 2 2 2 2 ];
para.patchSize = [ 35 35 ];
para.sampling_rate = 0.1;

[ bsp_descriptors ] = ExtractBSplinePatchFeature( rangeMap, ridgeMap, para );
%%

%% extract shape index local feature
para.patchSize = [ 35 35 ];
para.sampling_rate = 0.1;

[ si_descriptors ] = ExtractShapeIndexFeature( shapeIndex, ridgeMap, para );
%%

% [ contour ] = ComputeConvexConcaveBoundey( shape_index );