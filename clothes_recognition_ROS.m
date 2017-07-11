warning off
pctRunOnAll warning('off','all')
close all
clc

para.sensor = 'RH_fast'

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
vl_setup

if strcmp(para.sensor,'RH')
    scaleFactor = 0.5;
else
    scaleFactor = 0.2;
end

rangeMap = imresize( rangeMap, scaleFactor );
rangeMap = rangeMap * 1000;
rgbImage = imresize( rgbImage(:,:,end:-1:1), scaleFactor );
mask = imresize(clothes,size(rangeMap));
mask = round(mask*2);

tableCorners(:,1:2) = tableCorners (:,1:2) * scaleFactor;
tableCorners(:,3) = tableCorners (:,3) * 1000;

[ rangeMap shiftZ ] = ShiftRangeMap( rangeMap, tableCorners, 'RH' );

%% feature setting
para.local.bsp = 1;
para.local.finddd = 0;
para.local.lbp = 0;
para.local.sc = 0;
para.local.dlcm = 0;
para.local.sift = 0;

para.global.si = 1;
para.global.lbp = 1;
para.global.topo = 1;
para.global.dlcm = 0;
para.global.vol = 0
para.global.imm = 0;

is_norm = 1;

%% coding setting
kofkmeans = 256;
coding_opt = 'LLC'
pooling_opt = 'sum'
knn = 5

%% read code book 
flile_header = 'clothes_dataset';
%create firectory
dataset_dir = ['/home/kevin/',flile_header];
codebook_dir = [dataset_dir,'/Codebook/'];
load([codebook_dir,'code_book',num2str(kofkmeans),'_best.mat']);

%%

flag = true;
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

instance = [ local_feature, global_feature ];

% read classifier
load('classifier.mat')

[ instance ] = mapminmax( 'apply', instance', norm );
instance = instance';
[predict_label, accuracy, dec_values] = libsvmpredict( 0, instance, svm_struct);
clearvars -except predict_label;

switch predict_label
    case 1
        disp('the selected clothes is predicted as T-shirt');
    case 2  
        disp('the selected clothes is predicted as Shirt');
    case 3
        disp('the selected clothes is predicted as Sweater');
    case 4
        disp('the selected clothes is predicted as Jeans');
end
        