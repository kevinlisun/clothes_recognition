function [Prior, Mean, Cov] = gmm_iteropt(Data, Prior, Mean, Cov)

% dimensions
n = size(Data, 2);
k = size(Mean, 2);

% split data to GMM components having maximal posterior probability
[~, comp] = gmm_logmaxpost(Data, Prior, Mean, Cov);

% estimate new parameters of GMM components
for i = 1:k
    Data_i = Data(:,comp==i);
    Prior(i) = size(Data_i, 2) / n;
    Mean(:,i) = mean(Data_i, 2);
    Cov(:,:,i) = cov(Data_i');
end

end
