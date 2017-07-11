clear all
close all
clc

kofkmeans = 100;

addpath(fullfile(pwd,'FeatureExtraction/BSplineFitting'));
addpath(fullfile(pwd,'FeatureExtraction/SurfaceFeature'));
addpath(fullfile(pwd,'Simulator'));

%% experiment setting
% the file is start with date to distinguish
flile_header = '2014-06-20';
%create firectory
dataset_dir = ['D:\Dropbox\',flile_header];

% n_iteration is the number of flattening iteration in each experiment
n_iteration = 10;

% read code book 
codebook_dir = [dataset_dir,'\codebook'];
load([codebook_dir,'\code_book_bsp_',num2str(kofkmeans),'.mat']);
load([codebook_dir,'\code_book_bsp_si_',num2str(kofkmeans),'.mat']);

% read NFQ model
load([dataset_dir,'\model\NFQ.mat']);
nfq_model = model;

cloth_dir = '.\particles.txt';
table_dir = '.\data\table\particles.txt';
canonical_cloth_dir = '.\data\canoical\particles.txt';


for iter = 1:n_iteration
    [ model ] = ParseSimulatorData( cloth_dir, table_dir );
    [ canonical_model ] = ParseSimulatorData( canonical_cloth_dir, table_dir );
    
    % extract local feature
    [ bsp_descriptors si_descriptors ] = ExtractLocalFeatures( model.rangeMap, false );
    % coding
    [ bsp_code ] = Coding( bsp_descriptors, code_book_bsp );
    % get flattening strategy
    [ maxQvalue maxTheta ] = getMaxQ( bsp_code, nfq_model.normVec, nfq_model.NFQ );
    
    force_dir = [ cos(maxTheta), sin(maxTheta) ];
    [ force ] = GetForce( force_dir, model, canonical_model );
    
    forceVec = force.force_vector * min((max(10,force.force_strength)),30);
    graspPos = force.grasp_particle;
    pinPos = force.pin_particle;
    
    exeTime = 100;
    forceTime = [ 1, min(max(20,5+force.force_time),30)];
    MODE = 1;
    %% run scenario
    if MODE == 1
        cmd = ['.\Simulator ', num2str(exeTime), ' ',...
            num2str(forceVec(1)), ' ', num2str(forceVec(2)), ' ', num2str(forceVec(3)), ' ', num2str(graspPos(1)), ' ', num2str(graspPos(2)), ' ', ...
            num2str(forceTime(1)), ' ', num2str(forceTime(2)) ];
    else
        cmd = ['.\Simulator ', num2str(exeTime), ' ',...
            num2str(forceVec(1)), ' ', num2str(forceVec(2)), ' ', num2str(forceVec(3)), ' ', num2str(graspPos(1)), ' ', num2str(graspPos(2)), ' ', ...
            num2str(forceTime(1)), ' ', num2str(forceTime(2)), ' ', num2str(pinPos(1)), ' ', num2str(pinPos(2)), ' ', ...
            num2str(forceTime(1)), ' ', num2str(forceTime(2)) ]
    end
    system(cmd);
    
end


