% configuration
INPUT_IMG = './data_cmp/test.png';
OUTPUT_IMG = './out/mask.png';
RGB_MODEL = './out/rgb_model.mat';
RESIZE_FACTOR = 0.25;
% % ROI_COORDS = [129,120,514,514,129;27,415,420,30,27]; % kinect
ROI_COORDS = [1230.5,910.5,3938.5,3614.5,1230.5;698.5,2790.5,2858.5,762.5,698.5]; % RH

% paths
addpath('./libs/maxflow', './gmm');

% load image and color model
img = imread(INPUT_IMG);
rgbModel = load(RGB_MODEL);

% run the segmentation
[ptsFull, segMask] = grabcut_segmentation(img, rgbModel, RESIZE_FACTOR, ROI_COORDS);

% show result
plot_img(2, 2, 1, img);
plot_img(2, 2, 2, segMask);

% save image
mask = zeros(size(segMask));
mask(segMask) = 255;
imwrite(uint8(mask), OUTPUT_IMG);
