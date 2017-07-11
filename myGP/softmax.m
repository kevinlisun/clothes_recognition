function [ p ] = softmax(f, opt)

if strcmp(opt, 'logistic')
    p = zeros(size(f));
    p = 1 ./ ( 1 + exp(-f));
end

if strcmp(opt, 'probit')
    p = normcdf(f);
end