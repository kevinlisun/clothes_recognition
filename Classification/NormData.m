function [ varargout ] = NormData(X, model)

% this is a function to normal the data in vertical direction to mean = 0,
% std = 1

if nargin < 2
    model.mu = sum(X, 1)./size(X,1);
    model.sigma = std(X);
    
    X = X - repmat(model.mu,[size(X,1) 1]);
    X = X ./ repmat(model.sigma,[size(X,1) 1]);
    X(:,find(model.sigma==0)) = 0;
    varargout = {X, model};
else
    X = X - repmat(model.mu,[size(X,1) 1]);
    X = X ./ repmat(model.sigma,[size(X,1) 1]);
    X(:,find(model.sigma==0)) = 0;
    varargout = {X};
end