function transform = compute_pca_transform(X)

% perform PCA on normalized data (having zero mean)
mu = mean(X, 2);
Xn = X - repmat(mu, 1, size(X, 2));
[coeff, ~, latent] = pca(Xn');

% translation to move the data to mean
trans = [eye(3), -mu; 0 0 0 1];

% rotation to project the data to principal vectors
rotation = [coeff', zeros(3, 1); 0 0 0 1];

% scaling to normalize according to variances along principal vectors
scale = diag([1 ./ sqrt(latent); 1]);

% firstly translate, secondly rotate, thirdly scale
transform = scale * rotation * trans;

end
