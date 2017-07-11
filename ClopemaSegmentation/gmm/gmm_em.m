function [Prior, Mean, Cov] = gmm_em(Data, Prior, Mean, Cov, maxiter)

% initilization
[d, n] = size(Data);
k = size(Mean, 2);

for iter = 1:maxiter
    
    % E-step: compute posterior probability for GMM
    Prob = gmm_post(Data, Prior, Mean, Cov);
    
    % normalize probabilities for all data
    Probnorm = repmat(sum(Prob, 1), k, 1);
    Prob = Prob ./ Probnorm;
    
    % M-step: estimate new parameters
    for i = 1:k
        % compute new mean, covariance and prior
        prob_i = Prob(i,:);
        norm_i = sum(prob_i);
        mean_i = (Data * prob_i') / norm_i;
        X_i = Data - repmat(Mean(:,i), 1, n);
        Cov_i = repmat(prob_i, d, 1) .* X_i * X_i' / norm_i;
        prior_i = norm_i / n;
        
        % check that GMM model is valid
        [Prior(i), Mean(:,i), Cov(:,:,i)] = ...
            gmm_check(prior_i, mean_i, Cov_i);
    end
    
end
