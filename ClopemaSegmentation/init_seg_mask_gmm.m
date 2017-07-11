function [indGar, indTab] = ...
    init_seg_mask_gmm(rgb, Prior, Mean, Cov, logprobGarMax, logprobTabMin)

% compute GMM probabilities for all RGB values of all pixels
rgbProb = gmm_logsumpost(rgb, Prior, Mean, Cov);

% garment pixels have low probability and table pixels have high probability
indGar = find(rgbProb < logprobGarMax);
indTab = find(rgbProb > logprobTabMin);

% [~, ind] = sort(rgbProb);
% nInd = length(ind);
% indGar = ind(1:floor(0.05*nInd));
% indTab = ind(ceil(0.8*nInd):end);

end
