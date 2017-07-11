function [Prior, Mean, Cov] = gmm_quant(Data, k)

[dim, n] = size(Data);

% means, covariances, eigenvectors and eigenvalues for all classes
Mean = zeros(dim, k);
Cov = zeros(dim, dim, k);
V = zeros(dim, k);
e = zeros(1, k);

% initialize mean, covariance, eigvals and eigvecs for all data
[Mean(:,1), Cov(:,:,1), V(:,1), e(1)] = meancoveig(Data);

% initially all data are in the first class
c = ones(1, n);

for j = 2:k
    % find component with maximal eigenvalue
    [~, i] = max(e);
    
    % get corresponding eigenvector, data and their mean
    v_i = V(:,i);
    c_i = find(c==i);
    Data_i = Data(:,c_i);
    mean_i = Mean(:,i);
    
    % split data using a threshold
    c_ii = (v_i' * Data_i) <= (v_i' * mean_i);
    c_ij = ~c_ii;
    
    % relabel data
    c(c_i(c_ii)) = i;
    c(c_i(c_ij)) = j;
    
    % recompute means, covariances, eigvals and eigvecs for splitted data
    [Mean(:,i), Cov(:,:,i), V(:,i), e(i)] = meancoveig(Data_i(:,c_ii));
    [Mean(:,j), Cov(:,:,j), V(:,j), e(j)] = meancoveig(Data_i(:,c_ij));
end

% compute priors
Prior = zeros(1, k);
for i = 1:k
    Prior(i) = sum(c == i) / n;
end

end


function [m, Cov, v, lam] = meancoveig(Data)

% compute mean and covariance
m = mean(Data, 2);
Cov = cov(Data');

% compute eigvals and eigvecs and select the maximal one
[V, D] = eig(Cov);
[lam, i] = max(diag(D));
v = V(:,i);

end
