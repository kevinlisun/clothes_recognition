warning off
clear all
close all
clc

flag = true;

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
addpath(genpath('./RandomForest'));
addpath('./GP_MultClass');

vl_setup
startup

%% script setting
coding_opt = 'LLC'

para.local.bsp = 1;
para.local.lbp = 0;
para.local.sc = 0;
para.local.dlcm = 0;
para.local.sift = 0;

para.global.si = 1;
para.global.lbp = 1;
para.global.topo = 1;
para.global.dlcm = 0;

% the file is start with date to distinguish
flile_header = 'ProcessedData';
%create firectory
dataset_dir = ['/home/kevin/matlab_ws/',flile_header];

% clothes is the number of flattening experiments, n_iteration is the
% number of flattening iteration in each experiment [1:7,10:12,15:16];
clothes = [1:7,10:12,15:16];
captures = 1:30;
%% main loop

Instance = [];
Label1 = [];
Label2 = [];
ClothesID = [];

for iter_i = 1:length(clothes)
    clothes_i = clothes(iter_i);
    disp(['start read descriptors of clothes id: ', num2str(clothes_i), ' ...']);
    
    if clothes_i < 10
        current_dir = strcat(dataset_dir,'/0',num2str(clothes_i),'/');
    else
        current_dir = strcat(dataset_dir,'/',num2str(clothes_i),'/');
    end
    
    % read the label information
    labelFile = strcat(current_dir,'info.mat');
    load(labelFile);
    
    switch category
        case 't-shirt'
            label1 = 1;
        case 'shirt'
            label1 = 2;
        case 'thin-sweater'
            label1 = 3;
        case 'thick-sweater'
            label1 = 4;
        case 'hoodie'
            label1 = 5;
        case 'jean'
            label1 = 6;
        otherwise
            pause        
    end
    
    switch fabric % 1 2 3 3 1 4
        case 'thin-cotton'
            label2 = 1;
        case 'jaconet'
            label2 = 2;
        case 'thin-knitting'
            label2 = 3;
        case 'thick-knitting'
            label2 = 4;
        case 'thick-cotton'
            label2 = 5;
        case 'jean'
            label2 = 6;
        otherwise
            pause
    end
    
    % feature extraction
    for iter_j = 1:length(captures)
        
        capture_i = captures(iter_j);
        
        local_feature = [];
        global_feature = [];
        
        %% read features from the disk
        % read local features (code)
        localFeatureFile = strcat(current_dir,coding_opt,'_codes_capture',num2str(capture_i),'.mat');
        
        if ~exist(localFeatureFile,'file')
            continue;
        else
            load(localFeatureFile);
        end
        
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
        
        % read global features
        globalFeatureFile = strcat(current_dir,'global_descriptors_capture',num2str(capture_i),'.mat');
        load(globalFeatureFile);
        
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
        
        Instance = [ Instance; instance ];
        Label1 = [ Label1; label1 ];
        Label2 = [ Label2; label2 ];
        ClothesID = [ ClothesID; clothes_i ];
        
        
        clear instance;
    end
    %%
    disp(['fininsh coding of clothing ', num2str(clothes_i), ' ...']);
    clear label1 label2;
end

clearvars -except Instance Label1 Label2 ClothesID; 

[ Instance Label1 norm ] = prepareData( Instance, Label1 );
%% traning model for robot practical recognition
% train VSM model
svm_opt = '-c 1 -t 0';
svm_struct = libsvmtrain( Label1, Instance, svm_opt );
save('classifier.mat','svm_opt','norm','svm_struct');
    
%% classfication varification
fold = 10;
expNum = 10;

labelNum1 = length(unique(Label1));
labelNum2 = length(unique(Label2));

Accuracy1 = zeros(1,expNum);
Accuracy2 = zeros(1,expNum);
ConfMat1 = zeros(labelNum1,labelNum1,expNum);
ConfMat2 = zeros(labelNum2,labelNum2,expNum);

for expi = 1:expNum
    [ result_svm ] = x_fold_CV( Instance, Label1, fold, 'multiGP', svm_opt );
    Accuracy1(expi) = result_svm.accuracy;
    ConfMat1(:,:,expi) = result_svm.confMax;
end

std_1 = std(Accuracy1)
Accuracy1 = mean(Accuracy1);
ConfMat1 = mean(ConfMat1,3);

figure(1)
imagesc(ConfMat1);
Accuracy1

pause(5)

for expi = 1:1
    [ result3 ] = OneAgainstAllValidification( Instance, Label1, ClothesID, 'multiGP', svm_opt );
    accuracy3(expi,:) = result3.accuracy;
    Accuracy3(expi,:) = result3.Accuracy;
end

accuracy3 = mean(accuracy3)
Accuracy3 = mean(Accuracy3,1)   

figure(2)
imagesc(ConfMat2);
colormap(gray);
    
