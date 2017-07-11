warning off
clear all
close all
clc

addpath('./BSplineFitting');
addpath('./SurfaceFeature');
addpath('./SpatialPyramid');
addpath(genpath([pwd,'/GPML']));
addpath('./ShapeContent');
addpath('./Utilities');
addpath('./vlfeat/toolbox');


%% experiment setting
% the file is start with date to distinguish
flile_header = 'clothes_dataset';
%create firectory
dataset_dir = ['/home/kevin/',flile_header];

%% read code book 
codebook_dir = [dataset_dir,'/Codebook/'];
load([codebook_dir,'/code_book256.mat']);
code_book_bsp = code_book.bsp;

% compute the base function at the begining
knotVec = [ 0 0 0 0 1 2 2 2 2];
patchSize = [ 25 25 ];
uSize = fix(patchSize(2)/2)*2+1; % patch height
wSize = fix(patchSize(1)/2)*2+1; % patch length
[ C ] = ComputeUniformOpenBSplineBaseFun( knotVec, wSize, uSize );


B = [];
t = [1,7,18.5,30,36];
for i = 1:5
    for j = 1:5
        B = [ B; [t(i),t(j)] ];
    end
end

[ a b ] = sort(code_book.bsp_weights,'ascend');
code_book_bsp = code_book_bsp(b,:);

for i = 1:size(code_book_bsp);
    B(:,3) = code_book_bsp(i,:)';
    D = C*B;
    patch = reshape(D(:,3),[wSize uSize]);
    subplot(10,10,i)
    imagesc(patch)
% %     surf(patch)
% %     camlight right;
% %     lighting phong;
% %     shading interp
end
    
    