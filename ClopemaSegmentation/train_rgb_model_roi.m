close all;
clear;

% number of GMM components in color model of table
GMM_COMPS = 4;

% quantiles determining thresholds of table and garment probabilities in
% the learned color model
GAR_QUANT = 0.03;
TAB_QUANT = 0.20;

% directory containing training images of table
DATA_DIR = './data_cmp/';

% plotting settings
PLOT_FIG = true;
FROW = 2;
FCOL = 3;
PLOT_PTS_COUNT = 3000;

addpath('./gmm');

% load all PNG images from the directory
dirImgFiles = dir(strcat(DATA_DIR, '*.png'));
nImgs = numel(dirImgFiles);

% load rgb values of pixels in regions of interest for all images
rgb = zeros(3, 0);
for i = 1:nImgs
    % name of the image and ROI file
    imgFileName = dirImgFiles(i).name;
    roiFileName = strcat(imgFileName(1:end-4), '.mat');
    
    fprintf('Image %s (%d / %d)\n', imgFileName, i, nImgs);
    
    % load image
    img = imread(strcat(DATA_DIR, imgFileName));
    img = double(img) / 255;
    [h, w, ~] = size(img);
    
    % load polygonal ROI and use it to create a mask or use all pixels
    if exist(strcat(DATA_DIR, roiFileName), 'file')
        polyRoiDef = load(strcat(DATA_DIR, roiFileName));
        polyRoi = polyRoiDef.polyRoi;
        mask = roipoly(img, polyRoi(1,:), polyRoi(2,:));
        mask = (mask == 1);
    else
        mask = true(h, w);
    end
    
    % store RGB values
    imgRgb = reshape(img, h * w, 3)';
    imgRgb = imgRgb(:,mask);
    rgb = cat(2, rgb, imgRgb);
end

% estimate GMM probabilities for RGB values of table
watch('GMM estimation');
[Prior, Mean, Cov] = gmm_est(rgb, GMM_COMPS);
watch();

if PLOT_FIG
    subfig(FROW, FCOL, 1);
    hold on;
    plot_rgb_cube(rgb, PLOT_PTS_COUNT);
    plot_gmm(Prior, Mean, Cov, [0 1 0]);
    hold off;
    axis equal;
    axis([0 1 0 1 0 1]);
end

if PLOT_FIG
    rgbProb = gmm_logsumpost(rgb, Prior, Mean, Cov);
    subfig(FROW, FCOL, 2);
    plot_hists({rgbProb}, 0.01, 20, {[GAR_QUANT, TAB_QUANT]});
end

% determine thresholds; pixels having probability lower than threshGar are
% used to initialize color model of garment; pixels having probability
% higher than threshTab are used to initialize color model of table
prob = gmm_logsumpost(rgb, Prior, Mean, Cov);
threshGar = quantile(prob, GAR_QUANT);
threshTab = quantile(prob, TAB_QUANT);

save('./out/rgb_model_RH.mat', 'threshGar', 'threshTab', ...
    'Prior', 'Mean', 'Cov');
