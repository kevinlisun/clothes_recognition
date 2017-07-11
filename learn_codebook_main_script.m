warning off
clear all
close all
clc

code_book_dim = 256;
sampleNum = 50*10^3;

flag = true;
kofkmeans.bsp = code_book_dim;
kofkmeans.finddd = code_book_dim;
kofkmeans.lbp = code_book_dim;
kofkmeans.sc = code_book_dim; 
kofkmeans.dlcm = code_book_dim; 
kofkmeans.sift = code_book_dim; 

para.bsp = 1;
para.finddd = 0;
para.lbp = 0;
para.sc = 0;
para.dlcm = 0;
para.sift = 0;

addpath('./BSplineFitting');
addpath('./SurfaceFeature');
addpath('./SpatialPyramid');
addpath(genpath([pwd,'/GPML']));
addpath('./ShapeContent');
addpath('./Utilities');
addpath('./LLC');
addpath('./vlfeat/toolbox');
vl_setup
startup

%% experiment setting
% the file is start with date to distinguish
flile_header = 'clothes_dataset_RH';
%create firectory
dataset_dir = ['~/',flile_header];

% clothes is the number of flattening experiments, n_iteration is the
% number of flattening iteration in each experiment [1:4,5:7,10:12,15:16]
clothes = [1:50]
captures = 0:20;

%% initilize the feature set 
if para.bsp
    BSP_DESCRIPTORS = cell(length(clothes)*length(captures),1);
end
if para.finddd
    FINDDD_DESCRIPTORS = cell(length(clothes)*length(captures),1);
end
if para.lbp
    LBP_DESCRIPTORS = cell(length(clothes)*length(captures),1);
end
if para.sc
    SC_DESCRIPTORS = cell(length(clothes)*length(captures),1);
end
if para.dlcm
    DLCM_DESCRIPTORS = cell(length(clothes)*length(captures),1);
end
if para.sift
    SIFT_DESCRIPTORS = cell(length(clothes)*length(captures),1);
end
%%

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
        % get range map of iter i
        featureFile = strcat(current_dir,'Features/local_descriptors_capture',num2str(capture_i),'.mat');
        
        % Make sure the file exists (some gaps in the dataset)
        if ~exist(featureFile,'file')
            continue
        end

        % read features from the disk
        load(featureFile);
        
        % save descriptors to cell array
        if para.bsp
            BSP_DESCRIPTORS{(iter_i-1)*length(captures)+iter_j} = local_descriptors.bsp;
        end
        if para.finddd
            FINDDD_DESCRIPTORS{(iter_i-1)*length(captures)+iter_j} = local_descriptors.finddd;
        end        
        if para.lbp
            LBP_DESCRIPTORS{(iter_i-1)*length(captures)+iter_j} = local_descriptors.lbp;
        end
        if para.sc
            SC_DESCRIPTORS{(iter_i-1)*length(captures)+iter_j} = local_descriptors.sc;
        end
        if para.dlcm
            DLCM_DESCRIPTORS{(iter_i-1)*length(captures)+iter_j} = local_descriptors.dlcm;
        end
        if para.sift
            SIFT_DESCRIPTORS{(iter_i-1)*length(captures)+iter_j} = local_descriptors.sift;
        end
        
        clear bsp_descriptors si_descriptors sc_descriptors dlcm_descriptors;
        close all
    end
    %%
    disp(['fininsh reading features of clothing ', num2str(clothes_i), ' ...']);
end

%% learn code book using k-means clustering
if para.bsp
    all_bsp_descriptors = cell2mat(BSP_DESCRIPTORS);
end
if para.finddd
    all_finddd_descriptors = cell2mat(FINDDD_DESCRIPTORS);
end
if para.lbp
    all_lbp_descriptors = cell2mat(LBP_DESCRIPTORS);
end
if para.sc
    all_sc_descriptors = cell2mat(SC_DESCRIPTORS);
end
if para.dlcm
    all_dlcm_descriptors = cell2mat(DLCM_DESCRIPTORS);
    nanInx = sum(isnan(all_dlcm_descriptors),2);
    all_dlcm_descriptors(nanInx>0,:) = [];
end
if para.sift
    all_sift_descriptors = cell2mat(SIFT_DESCRIPTORS);
end

codebook_dir = [ dataset_dir,'/Codebook/' ];
if ~exist(codebook_dir,'dir')
    mkdir(codebook_dir);
end

if para.bsp
    save([codebook_dir,'all_bsp_descriptors.mat'],'all_bsp_descriptors');
    % sampleing 100k
    n = size(all_bsp_descriptors,1);
    seg = max(1,fix(n/sampleNum));
    index = 1:seg:n;
    all_bsp_descriptors = all_bsp_descriptors(index,:);
end
if para.finddd
    save([codebook_dir,'all_finddd_descriptors.mat'],'all_finddd_descriptors');
    % sampleing 100k
    n = size(all_finddd_descriptors,1);
    seg = max(1,fix(n/sampleNum));
    index = 1:seg:n;
    all_finddd_descriptors = all_finddd_descriptors(index,:);
end
if para.lbp
    save([codebook_dir,'all_lbp_descriptors.mat'],'all_lbp_descriptors');
    n = size(all_lbp_descriptors,1);
    seg = max(1,fix(n/sampleNum));
    index = 1:seg:n;
    all_lbp_descriptors = all_lbp_descriptors(index,:);
end
if para.sc
    save([codebook_dir,'all_sc_descriptors.mat'],'all_sc_descriptors');
    n = size(all_sc_descriptors,1);
    seg = fix(n/sampleNum);
    index = 1:seg:n;
    all_sc_descriptors = all_sc_descriptors(index,:);
end
if para.dlcm
    save([codebook_dir,'all_dlcm_descriptors.mat'],'all_dlcm_descriptors');
    n = size(all_dlcm_descriptors,1);
    seg = max(1,fix(n/sampleNum));
    index = 1:seg:n;
    all_dlcm_descriptors = all_dlcm_descriptors(index,:);
end
if para.sift
    save([codebook_dir,'all_sift_descriptors.mat'],'all_sift_descriptors');
    n = size(all_sift_descriptors,1);
    seg = max(1,fix(n/sampleNum));
    index = 1:seg:n;
    all_sift_descriptors = all_sift_descriptors(index,:);
end


%% perform clustering
options = zeros(1,14);
options(1) = 1; % display
options(2) = 1;
options(3) = 0.1; % precision
options(5) = 1; % initialization
options(14) = 100000; % maximum iterations

disp('Running k-means ...');
if para.bsp
    % %     centers = zeros(kofkmeans.bsp, size(all_bsp_descriptors,2));
    [ IDX,centers ] = kmeans( all_bsp_descriptors(1:100:end,:), kofkmeans.bsp );
    [ code_book.bsp, options, post, errlog ] = sp_kmeans(centers, all_bsp_descriptors, options);
    [ code_book.bsp_weights ] = computeWeigts( post );
end
if para.finddd
    % %     centers = zeros(kofkmeans.finddd, size(all_bsp_descriptors,2));
    [ IDX,centers ] = kmeans( all_finddd_descriptors(1:100:end,:), kofkmeans.finddd, 'emptyaction', 'drop' );
    [ code_book.finddd, options, post, errlog ] = sp_kmeans(centers, all_finddd_descriptors, options);
end
if para.lbp
    % %     centers = zeros(kofkmeans.lbp, size(all_lbp_descriptors,2));
    [ IDX,centers ] = kmeans( all_lbp_descriptors(1:100:end,:), kofkmeans.lbp, 'emptyaction', 'drop' );
    code_book.lbp = sp_kmeans(centers, all_lbp_descriptors, options);
end
if para.sc
    % %     centers = zeros(kofkmeans.sc, size(all_sc_descriptors,2));
    [ IDX,centers ] = kmeans( all_sc_descriptors(1:100:end,:), kofkmeans.sc, 'emptyaction', 'drop' );
    code_book.sc = sp_kmeans(centers, all_sc_descriptors, options);
end
if para.dlcm
    % %     centers = zeros(kofkmeans.dlcm, size(all_dlcm_descriptors,2));
    [ IDX,centers ] = kmeans( all_dlcm_descriptors(1:100:end,:), kofkmeans.dlcm, 'emptyaction', 'drop' );
    code_book.dlcm = sp_kmeans(centers, all_dlcm_descriptors, options);
end
if para.sift
    % %     centers = zeros(kofkmeans.dlcm, size(all_dlcm_descriptors,2));
    [ IDX,centers ] = kmeans( all_sift_descriptors(1:100:end,:), kofkmeans.sift, 'emptyaction', 'drop' );
    code_book.sift = sp_kmeans(centers, all_sift_descriptors, options);
end

code_book.kofkmeans = kofkmeans;

% save code book to disk
save([codebook_dir,'/code_book',num2str(code_book_dim),'.mat'],'code_book');

