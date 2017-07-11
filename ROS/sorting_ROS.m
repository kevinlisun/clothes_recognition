warning off
pctRunOnAll warning('off','all')
close all
clc

isInteractive = 0

tic

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
addpath('./3DVol');

vl_setup

para.sensor = 'RH_fast';

%% =====================================Category Recognition========================================
if strcmp(para.sensor, 'RH')
    scaleFactor = 0.5;
else
    scaleFactor = 0.2;
end

rangeMap = imresize( rangeMap, scaleFactor );
rangeMap = rangeMap * 1000;
rgbImage = imresize( rgbImage(:,:,end:-1:1), scaleFactor );
clothes = imfill(clothes,'holes');
mask = imresize(clothes,size(rangeMap));
mask = round(mask*2);

tableCorners(:,1:2) = tableCorners (:,1:2) * scaleFactor;
tableCorners(:,3) = tableCorners (:,3) * 1000;

[ rangeMap shiftZ ] = ShiftRangeMap( rangeMap, tableCorners, 'RH' );

%% feature setting
para.local.bsp = 1;
para.local.lbp = 0;
para.local.sc = 0;
para.local.dlcm = 0;
para.local.sift = 0;
para.local.finddd = 0;

para.global.si = 1;
para.global.lbp = 1;
para.global.topo = 1;
para.global.dlcm = 0;
para.global.imm = 0;
para.global.vol = 0;

is_norm = 1;
c = 5; %number of category

%% coding setting
kofkmeans = 256;
coding_opt = 'LLC'
pooling_opt = 'sum'
knn = 5

%% read code book 
flile_header = 'clothes_dataset_fast';
%create firectory
dataset_dir = ['/home/kevin/',flile_header];
codebook_dir = [dataset_dir,'/Codebook/'];
load([codebook_dir,'code_book',num2str(kofkmeans),'_demo.mat']);

%%

flag = false;
para.abheight = 0;

addpath('./Functions');
addpath('./BSplineFitting');
addpath('./SurfaceFeature');
addpath('./SpatialPyramid');
addpath(genpath([pwd,'/GPML']));
addpath('./ShapeContent');
addpath('./LLC');
addpath('./Utilities');
addpath('./vlfeat/toolbox');
addpath('./myGP');
vl_setup

%% surface analysis
para.mask = mask;

[ model ] = SurfaceAnalysis( rangeMap, para, flag );

% extract global feature
[ global_descriptors ] = ExtractGlobalFeatures( model, para, flag );
% extract local feature
[ local_descriptors] = ExtractLocalFeatures( model, para, flag );

disp(['fininsh feature extraction ...']);
%%


%% coding
if para.local.bsp
    if strcmp(coding_opt,'BOW')
        [ code.bsp ] = Coding( local_descriptors.bsp, code_book.bsp, is_norm );
    end
    if strcmp(coding_opt,'LLC')
        code.bsp = LLC_pooling( local_descriptors.bsp, code_book.bsp, code_book.bsp_weights, knn, pooling_opt );
    end
end
if para.local.lbp
    if strcmp(coding_opt,'BOW')
        [ code.lbp ] = Coding( local_descriptors.lbp, code_book.lbp, is_norm );
    end
    if strcmp(coding_opt,'LLC')
        code.lbp = LLC_pooling( local_descriptors.lbp, code_book.lbp,code_book.bsp_weights, knn, pooling_opt );
    end
end
if para.local.sc
    if strcmp(coding_opt,'BOW')
        [ code.sc ] = Coding( local_descriptors.sc, code_book.sc, is_norm );
    end
    if strcmp(coding_opt,'LLC')
        code.sc = LLC_pooling( local_descriptors.sc, code_book.sc, code_book.bsp_weights, knn, pooling_opt );
    end
end
if para.local.dlcm
    if strcmp(coding_opt,'BOW')
        [ code.dlcm ] = Coding( local_descriptors.dlcm, code_book.dlcm, is_norm );
    end
    if strcmp(coding_opt,'LLC')
        code.dlcm = LLC_pooling( local_descriptors.dlcm, code_book.dlcm, code_book.bsp_weights, knn, pooling_opt );
    end
end
if para.local.sift
    if strcmp(coding_opt,'BOW')
        [ code.sift ] = Coding( local_descriptors.sift, code_book.sift, is_norm );
    end
    if strcmp(coding_opt,'LLC')
        code.sift = LLC_pooling( local_descriptors.sift, code_book.sift, code_book.bsp_weights, knn, pooling_opt );
    end
end

disp(['fininsh coding of clothing ...']);

%% prediction

local_feature = [];
global_feature = [];

if para.local.bsp
    local_feature = [ local_feature, code.bsp ];
end
if para.local.lbp
    local_feature = [ local_feature, code.lbp ];
end
if para.local.sc
    local_feature = [ local_feature, code.sc ];
end
if para.local.dlcm
    local_feature = [ local_feature, code.dlcm ];
end
if para.local.sift
    local_feature = [ local_feature, code.sift ];
end


if para.global.lbp
    global_feature = [ global_feature, global_descriptors.lbp ];
end
if para.global.si
    global_feature = [ global_feature, global_descriptors.si ];
end
if para.global.topo
    global_feature = [ global_feature, global_descriptors.topo ];
end
if para.global.dlcm
    global_feature = [ global_feature, global_descriptors.dlcm];
end
if para.global.imm
    global_feature = [ global_feature, global_descriptors.imm];
end
if para.global.vol
    global_feature = [ global_feature, global_descriptors.vol];
end

instance = [ local_feature, global_feature ];

if ~isInteractive
    % read classifier
    load('classifier_demo.mat')
    
    [ instance ] = mapminmax( 'apply', instance', norm );
    instance = instance';
    [predict_label, accuracy, dec_values] = libsvmpredict( 0, instance, svm_struct);   
    prob = single(zeros(1,c));
    prob(predict_label) = 1;
else
    % read classifier
    load('classifier_gp.mat')
    gp_para.flag = false;
    [ instance ] = mapminmax( 'apply', instance', norm );
    instance = instance';
    % predictin
    [ predict_label prob fm ] = predictGPC_classic( gp_para.hyp, gp_para, gp_model.X, gp_model.y, gp_model, instance);
    predict_label = int8(predict_label);
    prob = single(prob);
    %%
end

switch predict_label
    case 1
        disp('the selected clothes is predicted as T-shirt');
    case 2  
        disp('the selected clothes is predicted as Shirt');
    case 3
        disp('the selected clothes is predicted as Sweater');
    case 4
        disp('the selected clothes is predicted as Jeans');
    case 5
        disp('the selected clothes is predicted as Towel');        
end

%% ========================================grasping====================================================


%% parameters ( set as default )
% flag controls whether show figures of not
if strcmp(para.sensor, 'RH')
    imresizeScale = 0.4;
else
    imresizeScale = 1;
end
%RESIZE_FACTOR = 0.5; % for segementation
r_shapeIndexfilter = 10;
showNum = 1;% grasping points want to show
numShow = 10;% fitted wrinkles want to show

%% read data, prepare data, and apply nomalization

rangeMap = model.rangeMap;
fittedSurface = model.fittedSurface;
ridgeMap = model.ridge;
contour = model.contour;
mask = model.mask;
shapeIndex = model.shapeIndex;

rgbImage = imresize(rgbImage,imresizeScale,'bilinear');
rangeMap = imresize(rangeMap,imresizeScale);

clothes = imresize(clothes,size(rangeMap),'nearest');
fittedSurface = imresize(fittedSurface,size(rangeMap),'bilinear');
ridgeMap = imresize(ridgeMap,size(rangeMap),'nearest');
% % contour = imresize(contour,size(rangeMap),'nearest');
shapeIndex = imresize(shapeIndex,size(rangeMap),'nearest');

disp('segmentation done!')
toc

rangeMap(~clothes) = NaN;
rangeMap(bwmorph(isnan(rangeMap),'majority')) = NaN;

%%

%% detect the topologies
[ contour ] = ComputeConvexConcaveBoundey( shapeIndex );

% detect clothes contour
[ clothes_conour ] = Detect_Clothes_Conour( clothes );
contour = contour + 2*clothes_conour;
% contour(contour>1) = 1;

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

% 
% height = zeros(length(graspingCandidates),1);
% for i = 1:length(graspingCandidates)
%     height(i) = graspingCandidates{i}.height;
% end
% 
% [height_sorted,idx] = sort(height,'descend');
% graspingCandidates = graspingCandidates(idx);

if flag == true
    ShowGraspingCandidates(fittedSurface, graspingCandidates, length(graspingCandidates));
end

[ ROS_INFO ] = graspingPoseEstamitation(graspingCandidates, ridgeMap, imresizeScale*scaleFactor, PL, PR, dispMH, dispMV );
position3D_ROS = ROS_INFO.position3D_ROS;
gripperDir_ROS = ROS_INFO.gripperDir_ROS;
position2D_ROS = ROS_INFO.position2D_ROS;
normal_ROS = ROS_INFO.normal_ROS;

grasp_from_table = 1;

if isempty(graspingCandidates)
    grasp_from_table = 1;
else
    for i = 1:size(position2D_ROS,1)
        tmp_x = round(position2D_ROS(i,1)*imresizeScale*scaleFactor);
        tmp_y = round(position2D_ROS(i,2)*imresizeScale*scaleFactor);
        rangeMap(tmp_y,tmp_x)
        if rangeMap(tmp_y,tmp_x) > 150
            grasp_from_table = 0;
            break;
        end
    end  
end

if grasp_from_table % clothes is too close to the table and need to grasp_from_table
    position2D_ROS = []
    position3D_ROS = [];
    [ clothes_conour ] = Detect_Clothes_Conour( clothes );
    
    [ position2D_ROS ] = get5EdgePoints( clothes_conour, imresizeScale*scaleFactor );
    
    for i = 1:5
        position3D_ROS(i,:) = get3Dpoint(position2D_ROS(i,:), PL, PR, dispMH, dispMV);
    end
end



clearvars -except grasp_from_table predict_label prob position3D_ROS gripperDir_ROS position2D_ROS normal_ROS;

disp('feature extraction is done!');
toc






        
