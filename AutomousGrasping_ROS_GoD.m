%load('/home/clopema/Desktop/new capture/RH/capture_2014_8_19_0_23.mat')
%     clear all
warning off %#ok<*WNOFF>
pctRunOnAll warning('off','all')
close all

addpath('./BSplineFitting');
addpath('./Functions');
addpath('./Classification');
addpath('./libSVM');
addpath('./SurfaceFeature');
addpath('./SpatialPyramid');
addpath(genpath([pwd,'/GPML']));
addpath('./ShapeContent');
addpath('./Utilities');
addpath('./vlfeat/toolbox');
addpath(genpath([pwd,'/geodesic']));
addpath('./ClothesUtilities');

%% directory of range map and RGB image    
%TABLE_MODEL = './clopema_segmentation/out/RH_table_model.mat'; % directory of trained table model

%% parameters ( set as default )
% flag controls whether show figures of not
flag = true;

imresizeScale = 0.2;
%RESIZE_FACTOR = 0.5; % for segementation
r_shapeIndexfilter = 10;
showNum = 1;% grasping points want to show
numShow = 10;% fitted wrinkles want to show

%% read data, prepare data, and apply nomalization
tic

rgbImage = imresize(rgbImage,imresizeScale,'bilinear');
rgbImage=rgbImage(:,:,end:-1:1);

% if flag == true
%     figure('name','show rgb image')
%     imagesc(rgbImage(end:-1:1,:,:));
% end

rangeMap = rangeMap*1000;
rangeMap = imresize(double(rangeMap),imresizeScale);


% load segmentation model
%table_model = load(TABLE_MODEL);
%% run the segmentation
%[ segBound, segMask ] = grabcut_segmentation(rgbImage, table_model, RESIZE_FACTOR);
%table = segMask.tableMask - segMask.garmentMask;
%clothes = segMask.garmentMask;
%table = imresize(table,size(rangeMap),'nearest');
%clothes = imresize(clothes,size(rangeMap),'nearest');

% % table = imresize(table,size(rangeMap),'nearest');
clothes = imfill(clothes,'holes');
clothes = imresize(clothes,size(rangeMap),'nearest');
% % table = table - clothes;
tableCorners(:,1:2) = tableCorners (:,1:2) * imresizeScale;
tableCorners(:,3) = tableCorners (:,3) * 1000;


disp('segmentation done!')
toc

% remove the table
% [ rangeMap shiftZ ] = ShiftRangeMap( rangeMap, table, 'RH' );
[ rangeMap shiftZ ] = ShiftRangeMap( rangeMap, tableCorners, 'RH' );
rangeMap(~clothes) = NaN;
rangeMap(bwmorph(isnan(rangeMap),'majority')) = NaN;

% % if flag == true
% %     subplot(2,2,1)
% %     title( 'orienginal range map');
% %     surf(rangeMap);
% %     %axis([ 50 450 50 300 mean(rangeMap(~isnan(rangeMap)))-150 mean(rangeMap(~isnan(rangeMap)))+250]);
% %     view(2)
% %     camlight right;
% %     lighting phong;
% %     shading interp
% % end
%%


%% surface fitting and shape index feature
% fit the surface using ploynomail 3-order BSpline surface fitting
para.knotVec = [ 0 0 0 0 1 2 2 2 2 ];
para.patchSize = [ 35 35 ];
para.ntimes = 35;
para.mask = clothes;

[ fittedSurface ] = BSplineSurfaceFitting( rangeMap, para );
fittedRealRange = fittedSurface + shiftZ;

disp('surface fitting done!');
toc

if flag == true
    figure('name', 'grasping features');
    subplot(2,2,1);
    title('ploynomail fitted range surface');
    
    surf(fittedSurface);
    [ oy ox ]  = find(~isnan(fittedSurface));
    ox = mean(ox);
    oy = mean(oy);
    r = 0.4*size(fittedSurface,1);
    axis([ox - r, ox + r, oy - r, oy + r, min(fittedSurface(:)), max(fittedSurface(:))]);
   
    view(2);
    camlight right;
    lighting phong;
    shading interp;
    pause(0.1);
end

% extract shape index feature on fitted surface and filter the feature
[ shapeIndex ] = Compute_shapeIndex( fittedSurface );
[  shapeIndex ] = SurfaceFeatureFiltMex( shapeIndex, r_shapeIndexfilter );

disp('shape analysis done!');
toc

if flag == true
    [ shapeIndexImage ] = ShowShapeIndex( fittedSurface, shapeIndex );
end
%%

%% detect the ridge points
para.nLayer = 3;
para.sigma_init = 0.5;
para.mode = 2;
para.threshold = [0.2,0.2,0.2];

[ ridgeMap ] = HierarchicalRidgeDetection( fittedSurface, para );
[ contour ] = ComputeConvexConcaveBoundey( shapeIndex );

% detect clothes contour
[ clothes_conour ] = Detect_Clothes_Conour( clothes );
contour = contour + 2*clothes_conour;
% contour(contour>1) = 1;

% non-maximum suppression
rangeImage = mapminmax(fittedSurface, 0, 255 );
% % ridgeMap = NonMaximumSppression( rangeImage, ridgeMap );
for i = 1:5
    ridgeMap = bwmorph(ridgeMap,'thin');
    contour = bwmorph(contour,'thin');
end

if flag == true
    ShowTopologyMap( fittedSurface, ridgeMap, contour );
end

disp('topology analysis is done!');
toc

%% Wrinkle Analysis
% % [ wrinkles ] = WrinkleAnalysis( rangeMap, ridgeMap, shapeIndex, flag );
% % 
% % if flag == true
% %     ShowWrinkles( fittedRealRange, wrinkles, numShow );
% % end


%% triplet descriptor and output

% 'height_mode' is heighest point priority
% 'abheight_mode' is the largest absolute height priority
% the default mode is the heirist score priority
grasping_mode = 'abheight_mode';

[graspingCandidates] = FindGraspingCandidates( fittedSurface, fittedSurface, shapeIndex, ridgeMap, contour, grasping_mode );

disp('grasping candidate is found!');
toc

% clearvars -except graspingCandidates dispMH dispMV PL PR imresizeScale; %rgbImage rangeMap ;
% % clearvars -except graspingCandidates dispMH dispMV PL PR imresizeScale; %rgbImage rangeMap ;

%% output - graspingCandidates
% graspingCandidates is a cell arry, which contain all the candidated ordered by the goodness score
% in each cell graspingCandidates{i} is a object of triplet, for
% example obj = graspingCandidates{i}, then we can get
% the grasping point x-y coordinate by obj.center,
% the normal by obj.normal,
% the gripper rotation angle [180,-180] in x-y plane by obj.rotation. and so on.

if flag == true
    ShowGraspingCandidates(fittedSurface, graspingCandidates, length(graspingCandidates));
end

% % % % the normal direction to grasp
% % % normal_ROS = graspingCandidates{1,1}.normal;
% % % % the x-y-z position of grasping point on clothes
% % % position2D = graspingCandidates{1,1}.position2D / imresizeScale; % Scale to original resolution
% % % % get 3D point
% % % position3D_ROS = get3Dpoint([position2D(1), position2D(2)], PL, PR, dispMH, dispMV);
% % % 
% % % % get left child
% % % leftChild2D = graspingCandidates{1,1}.leftChild2D / imresizeScale;
% % % leftChild3D_ROS = get3Dpoint([leftChild2D(1), leftChild2D(2)], PL, PR, dispMH, dispMV);
% % % % get right child
% % % rightChild2D = graspingCandidates{1,1}.rightChild2D / imresizeScale;
% % % rightChild3D_ROS = get3Dpoint([rightChild2D(1), rightChild2D(2)], PL, PR, dispMH, dispMV);

[ ROS_INFO ] = graspingPoseEstamitation( graspingCandidates, ridgeMap, imresizeScale, PL, PR, dispMH, dispMV );
position3D_ROS = ROS_INFO.position3D_ROS;
gripperDir_ROS = ROS_INFO.gripperDir_ROS;
position2D_ROS = ROS_INFO.position2D_ROS;
normal_ROS = ROS_INFO.normal_ROS;

disp('feature extraction is done!');
toc




