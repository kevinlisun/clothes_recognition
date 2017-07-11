function logsumpost = gmm_logsumpost(Data, Prior, Mean, Cov)

Post = gmm_post(Data, Prior, Mean, Cov);
logsumpost = log(sum(Post, 1));

end
