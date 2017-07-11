function [mat_f, mat_b] = grabcut(img, tri_f, tri_b, mat_f, mat_b)

VERBOSE = false;

% type of the neighborhood (4-connected or 8-connected)
NEIGH_TYPE = 8;

% number of GMM components to be used
GMM_COMPS = 3;

% weight of the binary potentials term
LAMBDA_1 = 5;
LAMBDA_2 = 45;
INF_VAL = NEIGH_TYPE * (LAMBDA_1 + LAMBDA_2) + 1;

% number of grabcut iterations
MAX_ITER = 3;

% size of the image
[height, width, ~] = size(img);
hw = height * width;

if VERBOSE, fprintf('INITIALIZATION\n'); end

% unknown pixels are complementary to foreground and background pixels
tri_u = subset_comp(hw, [tri_f; tri_b]);

% RGB values of all pixels and unknown pixels
Rgb = reshape(img, hw, 3)';
Rgb_tu = Rgb(:,tri_u);

if VERBOSE, watch('Neighborhood'); end

% build 4 or 8 neigborhood of pixels
[neigh, dist] = build_neigh(height, width, NEIGH_TYPE);
neigh1 = neigh(:,1);
neigh2 = neigh(:,2);

if VERBOSE, watch('Binary potentials'); end

% difference of neighboring pixels in RGB space
rgb_diff = Rgb(:,neigh1) - Rgb(:,neigh2);
rgb_diff = sum(rgb_diff.^2);

% compute beta as averare RGB space difference of neighboring pixels
beta = 1 / (2 * mean(rgb_diff));

% binary potentials for pairs of neigboring pixels forming n-links
Vf = LAMBDA_1 + LAMBDA_2 * dist .* exp(-beta * rgb_diff);
A = sparse([neigh1; neigh2], [neigh2; neigh1], [Vf, Vf]);

if VERBOSE, watch(); end

for iter = 1:MAX_ITER
    
    if VERBOSE, fprintf('ITERATION %i\n', iter); end
    
    % RGB values of foreground and background pixels
    Rgb_f = Rgb(:,mat_f);
    Rgb_b = Rgb(:,mat_b);
    
    % estimation of GMMs from indices from foreground and background pixels
    if iter == 1
        [Prior_f, Mean_f, Cov_f] = gmm_est(Rgb_f, GMM_COMPS);
        [Prior_b, Mean_b, Cov_b] = gmm_est(Rgb_b, GMM_COMPS);
    else
        [Prior_f, Mean_f, Cov_f] = gmm_est(Rgb_f, GMM_COMPS, Prior_f, Mean_f, Cov_f);
        [Prior_b, Mean_b, Cov_b] = gmm_est(Rgb_b, GMM_COMPS, Prior_b, Mean_b, Cov_b);
    end
    
    % negative logarithms of GMM probability distributions
    neglog_f = -gmm_logsumpost(Rgb_tu, Prior_f, Mean_f, Cov_f);
    neglog_b = -gmm_logsumpost(Rgb_tu, Prior_b, Mean_b, Cov_b);
    
    % unary potentials for all pixels forming t-links
    Df = zeros(2, hw);
    Df(:,tri_u) = [neglog_b; neglog_f];
    Df(1,tri_f) = INF_VAL;
    Df(2,tri_b) = INF_VAL;
    T = sparse(Df');
    
    % find max-flow
    if VERBOSE, watch('Maxflow'); end
    [~, lab] = maxflow(A, T);
    if VERBOSE, watch(); end
    
    % create new labelling
    mat_f = find(lab==0);
    mat_b = find(lab==1);
    
end

end
