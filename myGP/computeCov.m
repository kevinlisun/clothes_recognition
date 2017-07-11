function [ covMat ] = computeCov( x, y, para )
% this is the kernel of GP, k is the options
kernel = para.kernel;
sigma = ones(1,size(x,2)) * para.sigma;

switch kernel
    case 1
        kfunc = @(x,y) sigma.*x*y';
    case 2     
        kfunc = @(x,y) exp( -sigma*((x-y).^2)');
end

n1 = size(x,1);
n2 = size(y,1);

for i = 1:n1
    for j = 1:n2
        covMat(i,j) = kfunc(x(i,:),y(j,:));
    end
end

if n1 == n2
    covMat = covMat + 1e-6*eye(n1);
end