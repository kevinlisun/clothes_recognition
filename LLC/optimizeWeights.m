clear all 
clc

global x
global B
global codes

flile_header = 'clothes_dataset/Codebook';
%create firectory
dataset_dir = ['/home/kevin/',flile_header];

load([dataset_dir,'/all_bsp_descriptors.mat']);
load([dataset_dir,'/code_book256.mat']);
x = all_bsp_descriptors;
B = code_book.bsp;
knn = 5;
weights0 = ones(size(B,1),1) / size(B,1);

x = x(1:1000:end,:);

for i = 1:size(x,1)
    codesi = LLC_coding_appr(B, weights0', x(i,:), knn);
    codes(i,:) = codesi;
end

%'active-set', 'interior-point', 'sqp', or 'trust-region-reflective'
options = optimoptions('fmincon', 'FunValCheck', 'on', 'GradObj', 'on', 'DerivativeCheck', 'off', 'Algorithm', 'ctive-set', 'Display', 'iter-detailed', 'MaxFunEvals', 1000); %'quasi-newton'

[ weights ] = fmincon(@lossFunc, weights0, [], [], ones(1,length(weights0)), 1, zeros(size(weights0)), ones(size(weights0)), [], options);




