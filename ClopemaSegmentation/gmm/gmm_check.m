function [Prior, Mean, Cov] = gmm_check(Prior, Mean, Cov)

% throw out GMM components having zero prior
p = Prior > 0;
Prior = Prior(p);
Mean = Mean(:,p);
Cov = Cov(:,:,p);

% dimensions
[d, k] = size(Mean);

% ensure than covariance matrices are regular
for i = 1:k
    Cov(:,:,i) = Cov(:,:,i) + 1e-9 * eye(d);
end

end
