function Post = gmm_post(Data, Prior, Mean, Cov)

% compute posterior probability from likelihood and prior
Like = gmm_like(Data, Mean, Cov);
Post = Like .* repmat(Prior', 1, size(Like, 2));

end
