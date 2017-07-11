warning off
clear all
close all
clc

flag = true;
kofkmeans = 100;

addpath(fullfile(pwd,'FeatureExtraction/BSplineFitting'));
addpath(fullfile(pwd,'FeatureExtraction/SurfaceFeature'));
addpath(fullfile(pwd,'SpatialPyramid'));
addpath(fullfile(pwd,'Simulator'));

%% experiment setting
% the file is start with date to distinguish
flile_header = '2014-06-20';
%create firectory
dataset_dir = ['/home/kevin/Desktop/',flile_header];

% n_experiment is the number of flattening experiments, n_iteration is the
% number of flattening iteration in each experiment
n_experiment = 500;
n_interation = 10;
%% initilize the feature set 
BSP_DESCRIPTORS = cell(n_experiment*n_interation,1);
SI_DESCRIPTORS = cell(n_experiment*n_interation,1);
%%

%% main loop
for exp_i = 1:n_experiment
    disp(['start read descriptors of experiment ', num2str(exp_i), ' ...']);
    
    % feature extraction
    for iter_i = 1:n_interation
        current_dir = [dataset_dir,'/exp_',num2str(exp_i)];
         
      %%  
        
        % read features from the disk
        load([current_dir,'/bsp_descriptors_iter',num2str(iter_i),'.mat']);
        load([current_dir,'/si_descriptors_iter',num2str(iter_i),'.mat']);
        
        % save descriptors to cell array
        BSP_DESCRIPTORS{(exp_i-1)*n_interation+iter_i} = bsp_descriptors;
        SI_DESCRIPTORS{(exp_i-1)*n_interation+iter_i} = si_descriptors; 
        
        clear bsp_descriptors si_descriptors;
        close all
    end
    %%
    disp(['fininsh reading features of experiment ', num2str(exp_i), ' ...']);
end

%% learn code book using k-means clustering

all_bsp_descriptors = cell2mat(BSP_DESCRIPTORS);
all_bsp_si_descriptors = [ all_bsp_descriptors(:,1:25),cell2mat(SI_DESCRIPTORS) ];

save([dataset_dir,'/all_bsp_descriptors.mat'],'all_bsp_descriptors');
save([dataset_dir,'/all_bsp_si_descriptors.mat'],'all_bsp_si_descriptors');

% % [ code_book_bsp ] = kmeansCluster( all_bsp_descriptors, kofkmeans );
% % [ code_book_bsp_si ] = kmeansCluster( all_bsp_si_descriptors, kofkmeans );

%% perform clustering
options = zeros(1,14);
options(1) = 1; % display
options(2) = 1;
options(3) = 0.1; % precision
options(5) = 1; % initialization
options(14) = 100000; % maximum iterations

centers = zeros(kofkmeans, size(all_bsp_descriptors,2));

disp('Running k-means ...');
code_book_bsp = sp_kmeans(centers, all_bsp_descriptors, options);



% save code book to disk
codebook_dir = [dataset_dir,'/codebook/'];
save([codebook_dir,'/code_book_bsp_',num2str(kofkmeans),'.mat'],'code_book_bsp');
save([codebook_dir,'/code_book_bsp_si_',num2str(kofkmeans),'.mat'],'code_book_bsp_si');
