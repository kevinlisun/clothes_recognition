function [Prior, Mean, Cov] = gmm_kmeans(Data, k, maxiter)

% dimensions
[d, n] = size(Data);

% run k-means without no convergence warnings
warning('OFF', 'stats:kmeans:FailedToConverge');
[cluster, Mean] = kmeans(Data', k, 'MaxIter', maxiter);
warning('ON', 'stats:kmeans:FailedToConverge');

% k-means algorithm works with transposed data
Mean = Mean';

% initialize priors and covariances
Prior = zeros(1, k);
Cov = zeros(d, d, k);

% compute priors and covariances
for i = 1:k
  Data_i = Data(:,cluster==i);
  Prior(i) = size(Data_i, 2) / n;
  Cov(:,:,i) = cov(Data_i');
end

end
