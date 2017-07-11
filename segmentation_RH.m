warning off
clear all
close all
clc


%% parameters
flag = true;

addpath('./ClopemaSegmentation');


%% experiment setting
% the file is start with date to distinguish
flile_header = 'clothes_dataset';
%create firectory
dataset_dir = ['/home/kevin/',flile_header];


% clothes is the number of flattening experiments, n_iteration is the
% number of flattening iteration in each experiment [1:7,10:12,15:16]
clothes = [10];
captures = 0:30;

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
        dataFile = strcat(current_dir,'clothes_',num2str(clothes_i),'_capture_',num2str(capture_i));
        
        % Make sure the file exists (some gaps in the dataset)
        disp(strcat('loading ',dataFile,'...'));
        
        if ~exist(strcat(dataFile,'_rgb.png'),'file')
            continue
        end
        
        [ mask ] = copema_segmentation(strcat(dataFile,'_rgb.png'), strcat(dataFile,'_mask.png'), './ClopemaSegmentation/out/rgb_model_RH.mat');
        pause(1)
        close all
    end
    %%
    disp(['fininsh feature extraction of clothes ', num2str(iter_i), ' ...']);
end
