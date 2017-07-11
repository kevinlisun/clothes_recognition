warning off
clear all
close all
clc

addpath(fullfile(pwd,'FeatureExtraction\BSplineFitting'));
addpath(fullfile(pwd,'FeatureExtraction\SurfaceFeature'));
addpath(fullfile(pwd,'SpatialPyramid'));
addpath(fullfile(pwd,'Simulator'));

%% experiment setting
% the file is start with date to distinguish
flile_header = '2014-06-20';
%create firectory
dataset_dir = ['C:\Users\Kevin\Dropbox\',flile_header];

%% read code book 
codebook_dir = [dataset_dir,'\codebook\'];
load([codebook_dir,'\code_book_bsp_100.mat']);

% compute the base function at the begining
knotVec = [ 0 0 0 0 1 2 2 2 2 ];
patchSize = [ 35 35 ];
uSize = fix(patchSize(2)/2)*2+1; % patch height
wSize = fix(patchSize(1)/2)*2+1; % patch length
[ C ] = ComputeUniformOpenBSplineBaseFun( knotVec, wSize, uSize );

coordinates = code_book_bsp(:,end-1:end);
code_book_bsp(:,end-1:end) = [];


B = [];
t = [1,7,18.5,30,36];
for i = 1:5
    for j = 1:5
        B = [ B; [t(i),t(j)] ];
    end
end


for i = 1:size(code_book_bsp);
    B(:,3) = code_book_bsp(i,:)';
    D = C*B;
    patch = reshape(D(:,3),[wSize uSize]);
    subplot(10,10,i)
    surf(patch)
    camlight right;
    lighting phong;
    shading interp
end
    
    