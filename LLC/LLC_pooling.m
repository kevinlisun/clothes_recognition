% ========================================================================
% Pooling the llc codes to form the image feature
% USAGE: [beta] = LLC_pooling(feaSet, B, pyramid, knn)
% Inputs
%       feaSet      -the coordinated local descriptors
%       B           -the codebook for llc coding
%       pyramid     -the spatial pyramid structure
%       knn         -the number of neighbors for llc coding
% Outputs
%       beta        -the output image feature
%
% Written by Jianchao Yang @ IFP UIUC
% May, 2010
% ========================================================================

function [beta] = LLC_pooling(feaSet, B, weights, knn, pooling_opt)

% % nanInx = sum(isnan(feaSet),2);
% % feaSet(nanInx>0,:) = [];

feaSet = feaSet';
B = B';

dSize = size(B, 2);
nSmp = size(feaSet, 2);


idxBin = zeros(nSmp, 1);

% llc coding
llc_codes = LLC_coding_appr(B', weights, feaSet', knn);
llc_codes = llc_codes';

beta = zeros(dSize, 1);

if strcmp(pooling_opt,'max')
    beta = max(llc_codes, [], 2);
end
if strcmp(pooling_opt,'sum')
    beta = sum(llc_codes,2);
end

beta = beta./sqrt(sum(beta.^2));
% % beta = l2norm(beta);

beta = beta';
