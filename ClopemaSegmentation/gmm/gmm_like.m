function Like = gmm_like(Data, Mean, Cov)

% initilization
n = size(Data, 2);
k = size(Mean, 2);
Like = zeros(k, n);

% compute log-likelihood for each GMM component
for i = 1:k
    Mean_i = repmat(Mean(:,i), 1, n);
    Cov_i = Cov(:,:,i);
    X = Data - Mean_i;
    Like(i,:) = exp(-0.5 * sum(X .* (Cov_i \ X))) / sqrt(det(Cov_i));
end

end
