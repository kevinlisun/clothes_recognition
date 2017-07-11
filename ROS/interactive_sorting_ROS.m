%load('/home/clopema/Desktop/new capture/RH/capture_2014_8_19_0_23.mat')
%     clear all
warning off %#ok<*WNOFF>
pctRunOnAll warning('off','all')
close all

classifier = 'GP'
para.sensor = 'RH_fast'

addpath('./BSplineFitting');
addpath('./Functions');
addpath('./Classification');
addpath('./libSVM');
addpath('./SurfaceFeature');
addpath('./ClothesUtilities');
addpath('./SpatialPyramid');
addpath(genpath([pwd,'/GPML']));
addpath('./ShapeContent');
addpath('./Utilities');
addpath('./vlfeat/toolbox');
addpath(genpath('./RandomForest'));
addpath('./FINDDD');
addpath('./myGP');
addpath('./LLC');
addpath('./3DVol');
addpath('./SimpleFeatures');
addpath('./vlfeat/toolbox');
vl_setup

%% pre-processing
scaleFactor = 0.2;
rangeMap = imresize( rangeMap, scaleFactor );
rangeMap = rangeMap * 1000;
rgbImage = imresize( rgbImage(:,:,end:-1:1), scaleFactor );
clothes = imfill(clothes,'holes');
[ clothes ] = medfilt2( clothes );
mask = imresize(clothes,size(rangeMap));
mask = round(mask*2);


tableCorners(:,1:2) = tableCorners (:,1:2) * scaleFactor;
tableCorners(:,3) = tableCorners (:,3) * 1000;

[ rangeMap shiftZ ] = ShiftRangeMap( rangeMap, tableCorners, 'RH' );

%% script setting

flag = false;
para.abheight = 0;

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

para.isnorm = 1 % norm of data for each dimention
is_morm = 1 % norm of desriptos

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

%% surface analysis
para.mask = mask;

[ model ] = SurfaceAnalysis( rangeMap, para, flag );

if para.global.si + para.global.lbp + para.global.topo + para.global.dlcm + para.global.imm + para.global.vol > 0
    % extract global feature
    [ global_descriptors ] = ExtractGlobalFeatures( model, para, flag );
end
if para.local.bsp + para.local.finddd + para.local.lbp + para.local.sc + para.local.sift + para.local.finddd > 0
    % extract local feautre
    [ local_descriptors] = ExtractLocalFeatures( model, para, flag );
end

disp('fininsh feature extraction ...');
%%


%% coding
tic
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

disp('fininsh coding of clothing ...');

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

disp('coding is done!');
toc

if strcmp(classifier, 'GP')
    load('classifier_gp_demo.mat')
    gp_para.flag = false;
    if para.isnorm
        [ instance ] = mapminmax( 'apply', instance', norm );
        instance = instance';
    end
    % predictin
    [ predict_label prob fm ] = predictGPC_classic( gp_para.hyp, gp_para, gp_model.X, gp_model.y, gp_model, instance);
    predict_label = int8(predict_label);
    prob = single(prob);
    
% %     prob = prob + 0.5.*prob_old;
% %     prob = prob ./ sum(prob);
% %     [ junk predict_label ] = max(prob);
% %     predict_label = int8(predict_label);
else
    % read classifier
    % read classifier
    load('classifier_demo.mat')
    if para.isnorm
        [ instance ] = mapminmax( 'apply', instance', norm );
        instance = instance';
    end
    [predict_label, accuracy, dec_values] = libsvmpredict( 0, instance, svm_struct);
    prob = single(ones(1,c));
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

if ~flag
    scrsz = get(0,'ScreenSize');
    figure('Position',[scrsz(3)/2 scrsz(4) scrsz(3)/2 200]);
    title('Predictive Probablities from Gaussian Process');
    subplot(1,5,1)
    im = imread('./images/cat1.jpg');
    image(im);
    axis off
    hold on
    if predict_label == 1
        mcolor = 'r';
    else
        mcolor = 'k';
    end
    lbl = strtrim(cellstr(num2str(prob(1))));
    text(250, 250, lbl,'color',mcolor,...
        'HorizontalAlignment','center','VerticalAlignment','middle', 'FontSize', 20);
    hold on
    subplot(1,5,2)
    im = imread('./images/cat2.jpg');
    image(im);
    axis off
    hold on
    if predict_label == 2
        mcolor = 'r';
    else
        mcolor = 'k';
    end
    lbl = strtrim(cellstr(num2str(prob(2))));
    text(250, 250, lbl,'color',mcolor, 'FontSize', 1, ...
        'HorizontalAlignment','center','VerticalAlignment','middle');
    hold on
    subplot(1,5,3)
    im = imread('./images/cat3.jpg');
    image(im);
    axis off
    hold on
    if predict_label == 3
        mcolor = 'r';
    else
        mcolor = 'k';
    end
    lbl = strtrim(cellstr(num2str(prob(3))));
    text(250, 250, lbl,'color',mcolor,...
        'HorizontalAlignment','center','VerticalAlignment','middle', 'FontSize', 20);
    hold on
    
    subplot(1,5,4)
    im = imread('./images/cat4.jpg');
    image(im);
    axis off
    hold on
    if predict_label == 4
        mcolor = 'r';
    else
        mcolor = 'k';
    end
    lbl = strtrim(cellstr(num2str(prob(4))));
    text(250, 250, lbl,'color',mcolor,...
        'HorizontalAlignment','center','VerticalAlignment','middle', 'FontSize', 20);
    hold on
    subplot(1,5,5)
    im = imread('./images/cat5.jpg');
    image(im);
    axis off
    hold on
    if predict_label == 5
        mcolor = 'r';
    else
        mcolor = 'k';
    end
    lbl = strtrim(cellstr(num2str(prob(5))));
    text(250, 250, lbl,'color',mcolor,...
        'HorizontalAlignment','center','VerticalAlignment','middle', 'FontSize', 20);
    
end

toc
disp('predicting is done!')

%% ========================================grasping====================================================


%% parameters ( set as default )
% flag controls whether show figures of not
flag = false;

imresizeScale = 1;
%RESIZE_FACTOR = 0.5; % for segementation
r_shapeIndexfilter = 10;
showNum = 1;% grasping points want to show
numShow = 10;% fitted wrinkles want to show

%% read data, prepare data, and apply nomalization
tic

rgbImage = imresize(rgbImage,imresizeScale,'bilinear');
rangeMap = imresize(double(rangeMap),imresizeScale);
shiftZ = imresize(double(shiftZ),imresizeScale);

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


%% surface fitting and shape index feature
if ~isempty(model.fittedSurface)
    fittedSurface = model.fittedSurface;
    fittedSurface = imresize(fittedSurface,imresizeScale);
else
    % fit the surface using ploynomail 3-order BSpline surface fitting
    para.knotVec = [ 0 0 0 0 1 2 2 2 2 ];
    para.patchSize = [ 35 35 ];
    para.ntimes = 15;
    para.mask = clothes;
    
    [ fittedSurface ] = BSplineSurfaceFitting( rangeMap, para );
    fittedRealRange = fittedSurface + shiftZ;
    
    disp('surface fitting done!');
    toc
    
    if flag == true
        figure(1);
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
end

if ~isempty(model.shapeIndex)
    shapeIndex = model.shapeIndex;
    shapeIndex = imresize(shapeIndex,imresizeScale);
else
    tic
    % extract shape index feature on fitted surface and filter the feature
    [ shapeIndex ] = Compute_shapeIndex( fittedSurface );
    [  shapeIndex ] = SurfaceFeatureFiltMex( shapeIndex, r_shapeIndexfilter );
    
    disp('shape analysis done!');
    toc
    
    if flag == true
        [ shapeIndexImage ] = ShowShapeIndex( fittedSurface, shapeIndex );
    end
end
%%

%% detect the ridge points
if ~isempty(model.ridge)
    ridgeMap = model.ridge;
    contour = model.contour;
    ridgeMap = imresize(ridgeMap,imresizeScale);
    contour = imresize(contour,imresizeScale);
else
    tic
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
    rangeImage = mapminmax(fittedSurface, 0, 300 );
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
end


%% triplet descriptor and output

% 'height_mode' is heighest point priority
% 'abheight_mode' is the largest absolute height priority
% the default mode is the heirist score priority
tic

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

[ ROS_INFO ] = graspingPoseEstamitation( graspingCandidates, ridgeMap, imresizeScale*scaleFactor, PL, PR, dispMH, dispMV );
position3D_ROS = ROS_INFO.position3D_ROS;
gripperDir_ROS = ROS_INFO.gripperDir_ROS;
position2D_ROS = ROS_INFO.position2D_ROS;
normal_ROS = ROS_INFO.normal_ROS;

if is_t3 % grasp_from_table only active in table 2
    grasp_from_table = 0.5;
    count = 0;

    if isempty(graspingCandidates)
        grasp_from_table = 1;
    else
        for i = 1:size(position2D_ROS,1)
            tmp_x = round(position2D_ROS(i,1)*imresizeScale*scaleFactor);
            tmp_y = round(position2D_ROS(i,2)*imresizeScale*scaleFactor);
            rangeMap(tmp_y,tmp_x)
            if rangeMap(tmp_y,tmp_x) < 100
                grasp_from_table = 1;
                break;
            end
            if rangeMap(tmp_y,tmp_x) > 250
                grasp_from_table = 0;
                break;
            end
        end
        
        if grasp_from_table == 0.5
            grasp_from_table = round(rand(1));
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
else
    grasp_from_table = 0;
end
    

disp('feature extraction is done!');
toc




