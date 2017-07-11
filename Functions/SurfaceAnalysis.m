function [ result ] = SurfaceAnalysis( rangeMap, para, flag )

mask = para.mask;

if para.abheight
    % shift the depth map tp the absoluate height
    [ rangeMap shiftZ ] = rangeMap2abHeight( rangeMap, mask==1, 'RH' );
end

if para.global.si + para.global.topo + para.local.bsp + para.local.finddd == 0
    result.rangeMap = rangeMap;
    result.mask = mask;
    result.fittedSurface = [];
    result.ridge = [];
    result.contour = [];
    result.shapeIndex = [];
    return;
end

%% show range image
if flag == true
    scrsz = get(0,'ScreenSize');
    figure('Position',[1 scrsz(4)/2 800 800]);
    subplot(2,2,1)
    img = rangeMap;
    img(mask~=2)=NaN;
    surf(img);
    [ oy ox ]  = find(~isnan(img));
    ox = mean(ox);
    oy = mean(oy);
    r = 0.4*size(img,1);
    axis([ox - r, ox + r, oy - r, oy + r, min(img(:)), max(img(:))]);    
    view(2);
    camlight right;
    lighting phong;
    shading interp;
    title('range map of iter i');
    pause(0.1);
end


%% surface shape index analysis
para.knotVec = [ 0 0 0 0 1 2 2 2 2 ];

if strcmp(para.sensor, 'RH')
    para.patchSize = [ 45 45 ];
    para.ntimes = 45;
elseif strcmp(para.sensor, 'RH_fast')
    para.patchSize = [ 23 23 ];
    para.ntimes = 23;
elseif strcmp(para.sensor, 'kinect')
    para.patchSize = [ 23 23 ];
    para.ntimes = 23;
else
    disp('ERROR, PLS input the sensor!');
end

para.mask = mask==2;

disp('bspline surface fitting ...')
[ fittedSurface ] = BSplineSurfaceFitting( rangeMap, para );

if flag == true
    subplot(2,2,1);
    img = fittedSurface;
    surf(img);
    [ oy ox ]  = find(~isnan(img));
    ox = mean(ox);
    oy = mean(oy);
    r = 0.4*size(img,1);
    axis([ox - r, ox + r, oy - r, oy + r, min(img(:)), max(img(:))]);    
    view(2);
    camlight right;
    lighting phong;
    shading interp;
    title('fitted depth surface');
    pause(0.1);
end

%%

%% shapeIndex analysis
if strcmp(para.sensor, 'RH')
    r_shapeIndexfilter = 7;
elseif strcmp(para.sensor, 'RH_fast')
    r_shapeIndexfilter = 3;
elseif strcmp(para.sensor, 'kinect')
    r_shapeIndexfilter = 3;
end

[ shapeIndex ] = Compute_shapeIndex( fittedSurface );
[  shapeIndex ] = SurfaceFeatureFiltMex( shapeIndex, r_shapeIndexfilter );

if flag == true
    [ shapeIndexIMG ] = ShowShapeIndex( fittedSurface, shapeIndex );
end
%%

%% topolody analysis
% ridge detection using multiple layers
para.nLayer = 3;
para.sigma_init = 0.5;
para.mode = 2;
para.threshold = [0.05,0.1,0.15];

disp('topology analysis ..')
[ ridgeMap ] = HierarchicalRidgeDetection( fittedSurface, para );
ridgeMap(shapeIndex~=7&shapeIndex~=8) = 0;

if strcmp(para.sensor, 'RH_fast')  
    % detect clothes contour using boundary of convex and concave surfaces
    [ contour ] = ComputeConvexConcaveBoundey( shapeIndex );    
else % sensor is 'RH' or 'kinect'
    % compute the wrinkle's contours using zero-crossing of second order
    % derivitive
    [ contour ] = ComputeZeroCrossingof2ndDerivative( fittedSurface, para );
end

% non-maximum suppression (thining)
for i = 1:10
    ridgeMap = bwmorph(ridgeMap,'thin');
    contour = bwmorph(contour,'thin');
end
%%

if flag == true
    ShowTopologyMap( fittedSurface, ridgeMap, contour );
end

% output
result.rangeMap = rangeMap;
result.fittedSurface = fittedSurface;
result.ridge = ridgeMap;
result.contour = contour;
result.mask = mask;
result.shapeIndex = shapeIndex;


