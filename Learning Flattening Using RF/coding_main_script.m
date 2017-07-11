warning off
clear all
close all
clc

flag = true;
kofkmeans = 100;

addpath(fullfile(pwd,'FeatureExtraction/BSplineFitting'));
addpath(fullfile(pwd,'FeatureExtraction/SurfaceFeature'));
addpath(fullfile(pwd,'Simulator'));

%% experiment setting
% the file is start with date to distinguish
flile_header = '2014-06-20';
%create firectory
dataset_dir = ['/home/kevin/Desktop/',flile_header];

% n_experiment is the number of flattening experiments, n_iteration is the
% number of flattening iteration in each experiment
n_experiment = 2000;
n_interation = 10;
%% read code book 
codebook_dir = [dataset_dir,'/codebook/'];
load([codebook_dir,'/code_book_bsp_',num2str(kofkmeans),'.mat']);
% load([codebook_dir,'/code_book_bsp_si_',num2str(kofkmeans),'.mat']);

%% main loop
for exp_i = 1:n_experiment
    disp(['start coding of experiment ', num2str(exp_i), ' ...']);
    
    % feature extraction
    for iter_i = 1:n_interation
        current_dir = [dataset_dir,'/exp_',num2str(exp_i)];
         
      %%  
        
        % read features from the disk
        load([current_dir,'/bsp_descriptors_iter',num2str(iter_i),'.mat']);
%         load([current_dir,'/si_descriptors_iter',num2str(iter_i),'.mat']);
        
        % save descriptors to cell array
        [ bsp_code ] = Coding( bsp_descriptors, code_book_bsp );
%         bsp_si_descriptors = [ bsp_descriptors(:,1:25), si_descriptors ];
%         [ bsp_si_code ] = Coding( bsp_si_descriptors, code_book_bsp_si ); 
        save([current_dir,'/bsp_code_iter',num2str(iter_i),'.mat'],'bsp_code')
%         save([current_dir,'/bsp_si_code_iter',num2str(iter_i),'.mat'],'bsp_si_code')
        
        clear bsp_descriptors si_descriptors bsp_code bsp_si_code;
        close all
    end
    %%
    disp(['fininsh coding of experiment ', num2str(exp_i), ' ...']);
end

%% learn code book using k-means clustering

