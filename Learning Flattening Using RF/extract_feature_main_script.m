warning off
clear all
close all
clc

flag = false;

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
n_experiment = 2000;
n_interation = 10;
%% setting wrinkld cloth initalization parameters
p_range_row = [ 15 40 ];
p_range_col = [ 15, 30 ];
f_strength_range = [ 20 30 ];
f_time_range = [ 15 25 ];
%%

%% main loop

for exp_i = 1:n_experiment
    disp(['start feature extracting of experiment ', num2str(exp_i), ' ...']);
    
    % feature extraction
    for iter_i = 1:n_interation
        current_dir = [dataset_dir,'/exp_',num2str(exp_i)];
        % get range map of iter i
        cloth_dir = [current_dir,'/particles_iter',num2str(iter_i),'.txt'];
        canonical_cloth_dir = './data/canoical/particles.txt';
        table_dir = './data/table/particles.txt';
        [ model ] = ParseSimulatorData( cloth_dir, table_dir );
        [ canonical_model ] = ParseSimulatorData( canonical_cloth_dir, table_dir );
        
        %% show range image
        rangeMap = model.rangeMap;
        if flag == true
            figure('name', 'range map of iter i');
            surf(rangeMap);
            axis([0 640 0 480 -360-100 -330+150]);
            view([-100, -500 , 500]);
            camlight right;
            lighting phong;
            shading interp;
        end
        %%
        
        % extract local feature
        [ bsp_descriptors si_descriptors ] = ExtractLocalFeatures( rangeMap, flag );
        
        % save features to the disk
        save([current_dir,'/bsp_descriptors_iter',num2str(iter_i),'.mat'],'bsp_descriptors');
        save([current_dir,'/si_descriptors_iter',num2str(iter_i),'.mat'],'si_descriptors');
     
        % computer value for each state and use this to computer reward
        [ value(iter_i) ] = ComputeStateValues( model, canonical_model ); 
        
        
        % save reward to disk
        if iter_i > 1
            reward = value(iter_i-1) - value(iter_i);
            save([current_dir,'/reward_iter',num2str(iter_i-1),'.mat'],'reward');
        end
        
        clear bsp_descriptors si_descriptors reward;
        close all
    end
    %%
    save([current_dir,'/value_1to10','.mat'],'value');
    disp(['fininsh feature extraction of experiment ', num2str(exp_i), ' ...']);
end
