function [Prior, Mean, Cov] = gmm_est(Data, k, Prior, Mean, Cov)

VERBOSE = false;

% which algorithms should be used for GMM estimation
INIT_ALG = 'quant';
REFINE_ALG = 'iteropt';

% iteration settings for individual algorithms
KMEANS_ITER = 20;
EM_ITER = 10;
EMGM_ITER = 10;

if VERBOSE, watch('GMM initialization'); end

% initialize by k-means, quantization or EMGM
if ~exist('Prior', 'var') || ~exist('Mean', 'var') || ~exist('Cov', 'var')
    if strcmp(INIT_ALG, 'kmeans')
        [Prior, Mean, Cov] = gmm_kmeans(Data, k, KMEANS_ITER);
    elseif strcmp(INIT_ALG, 'quant')
        [Prior, Mean, Cov] = gmm_quant(Data, k);
    elseif strcmp (INIT_ALG, 'emgm')
        [Prior, Mean, Cov] = gmm_emgm(Data, k, EMGM_ITER);
    end
end

if VERBOSE, watch('GMM refinement'); end

% refine by EM-algorithm, iterative optimization or EMGM library
if strcmp(REFINE_ALG, 'em')
    [Prior, Mean, Cov] = gmm_em(Data, Prior, Mean, Cov, EM_ITER);
elseif strcmp(REFINE_ALG, 'iteropt')
    [Prior, Mean, Cov] = gmm_iteropt(Data, Prior, Mean, Cov);
elseif strcmp (REFINE_ALG, 'emgm')
    [~, comp] = max(gmm_loglike(Data, Mean, Cov), [], 1);
    [Prior, Mean, Cov] = gmm_emgm(Data, comp, EMGM_ITER);
end

if VERBOSE, watch(); end

% check that GMM model is valid
[Prior, Mean, Cov] = gmm_check(Prior, Mean, Cov);

end


% use EMGM library for GMM estimation
function [Prior, Mean, Cov] = gmm_emgm(Data, init, maxiter)

[~, model] = emgm(Data, init, maxiter);
Prior = model.weight;
Mean = model.mu;
Cov = model.Sigma;
    
end
