function [logmaxpost, maxcomp] = gmm_logmaxpost(Data, Prior, Mean, Cov)

Post = gmm_post(Data, Prior, Mean, Cov);
[maxpost, maxcomp] = max(Post, [], 1);
logmaxpost = log(maxpost);

end
