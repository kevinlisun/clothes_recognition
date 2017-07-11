warning off
clear all
close all
clc

addpath(fullfile(pwd,'FeatureExtraction\BSplineFitting'));
addpath(fullfile(pwd,'FeatureExtraction\SurfaceFeature'));
addpath(fullfile(pwd,'Simulator'));

%% experiment setting
% the file is start with date to distinguish
flile_header = '2014-06-20';
%create firectory
dataset_dir = ['D:\Sythetic_Data\',flile_header];

% n_experiment is the number of flattening experiments, n_iteration is the
% number of flattening iteration in each experiment
n_experiment = 3000;
n_interation = 10;

%%
cmd = 'd:'
system(cmd);
%% cleaning
for exp_i = 2000:n_experiment
    disp(['start feature extracting of experiment ', num2str(exp_i), ' ...']);
    
    % feature extraction
    for iter_i = 1:n_interation
        current_dir = [dataset_dir,'\exp_',num2str(exp_i)];
        % get range mapof iter i
        constraints_dir = [current_dir,'\constraint_iter',num2str(iter_i),'.txt'];
   
        cmd = ['del ', '"', constraints_dir, '"' ];
        system(cmd);
    end
    %%
    disp(['clean experiment ', num2str(exp_i), ' ...']);
end
