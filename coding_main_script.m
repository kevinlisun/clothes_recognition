warning off
clear all
close all
clc

flag = true;
 
para.bsp = 1;
para.finddd = 0;
para.lbp = 0;
para.sc = 0;
para.dlcm = 0;
para.sift = 0;
is_norm = 1;

addpath('./BSplineFitting');
addpath('./LLC');
addpath('./SurfaceFeature');
addpath('./Functions');
addpath('./FINDDD');
addpath(genpath([pwd,'/GPML']));
addpath('./ShapeContent');
addpath('./Utilities');
addpath('./vlfeat/toolbox');
vl_setup
startup

%% script setting
% the file is start with date to distinguish
flile_header = 'clothes_dataset_RH';
%create firectory
dataset_dir = ['~/',flile_header];

% clothes is the number of flattening experiments, n_iteration is the
% number of flattening iteration in each experiment [1:7,10:12,15:16]
clothes = [1:50];
captures = 0:20;
kofkmeans = 256;
coding_opt = 'LLC'
pooling_opt = 'sum'
knn = 5

%% read code book 
codebook_dir = [dataset_dir,'/Codebook/'];
load([codebook_dir,'code_book',num2str(kofkmeans),'.mat']);

%% main loop
for iter_i = 1:length(clothes)
    clothes_i = clothes(iter_i);
    disp(['start read descriptors of clothes id: ', num2str(clothes_i), ' ...']);
    
    if clothes_i < 10
        current_dir = strcat(dataset_dir,'/0',num2str(clothes_i),'/');
    else
        current_dir = strcat(dataset_dir,'/',num2str(clothes_i),'/');
    end
    
    % feature extraction
    for iter_j = 1:length(captures)
        capture_i = captures(iter_j);
        % read features from the disk
        featureFile = strcat(current_dir,'Features/local_descriptors_capture',num2str(capture_i),'.mat');
        
        if ~exist(featureFile,'file')
            continue;
        end
        
        load(featureFile);
        
        %% coding
        if para.bsp
            if strcmp(coding_opt,'BOW')
                [ code.bsp ] = Coding( local_descriptors.bsp, code_book.bsp, is_norm );
            end
            if strcmp(coding_opt,'LLC')
                code.bsp = LLC_pooling( local_descriptors.bsp, code_book.bsp, code_book.bsp_weights, knn, pooling_opt );
            end
        end
        if para.finddd
            if strcmp(coding_opt,'BOW')
                [ code.finddd ] = Coding( local_descriptors.finddd, code_book.finddd, is_norm );
            end
            if strcmp(coding_opt,'LLC')
                code.finddd = LLC_pooling( local_descriptors.finddd, code_book.finddd, code_book.bsp_weights, knn, pooling_opt );
            end
        end
        if para.lbp
            if strcmp(coding_opt,'BOW')
                [ code.lbp ] = Coding( local_descriptors.lbp, code_book.lbp, is_norm );
            end
            if strcmp(coding_opt,'LLC')
                code.lbp = LLC_pooling( local_descriptors.lbp, code_book.lbp,code_book.bsp_weights, knn, pooling_opt );
            end
        end
        if para.sc
            if strcmp(coding_opt,'BOW')
                [ code.sc ] = Coding( local_descriptors.sc, code_book.sc, is_norm );
            end
            if strcmp(coding_opt,'LLC')
                code.sc = LLC_pooling( local_descriptors.sc, code_book.sc, code_book.bsp_weights, knn, pooling_opt );
            end
        end
        if para.dlcm
            if strcmp(coding_opt,'BOW')
                [ code.dlcm ] = Coding( local_descriptors.dlcm, code_book.dlcm, is_norm );
            end
            if strcmp(coding_opt,'LLC')
                code.dlcm = LLC_pooling( local_descriptors.dlcm, code_book.dlcm, code_book.bsp_weights, knn, pooling_opt );
            end
        end
        if para.sift
            if strcmp(coding_opt,'BOW')
                [ code.sift ] = Coding( local_descriptors.sift, code_book.sift, is_norm );
            end
            if strcmp(coding_opt,'LLC')
                code.sift = LLC_pooling( local_descriptors.sift, code_book.sift, code_book.bsp_weights, knn, pooling_opt );
            end
        end
        
        code_dir = [ current_dir, 'Codes' ];
        if ~exist(code_dir,'dir')
            mkdir(code_dir);
        end
              
        save([code_dir,'/',coding_opt,'_codes_capture',num2str(capture_i),'.mat'],'code')
        
        clear code;
    end
    %%
    disp(['fininsh coding of clothing ', num2str(clothes_i), ' ...']);
end

