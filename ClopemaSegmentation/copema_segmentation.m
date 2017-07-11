function [mask] = copema_segmentation(INPUT_IMG, OUTPUT_IMG, RGB_MODEL)

% % % configuration
% % INPUT_IMG = './data_cmp/test.png';
% % OUTPUT_IMG = './out/mask.png';
% % RGB_MODEL = './out/rgb_model.mat';
RESIZE_FACTOR = 0.5;
ROI_COORDS = [129,120,514,514,129;27,415,420,30,27]; % kinect

RRROI_COORDS = [1230.5,910.5,3938.5,3614.5,1230.5;698.5,2790.5,2858.5,762.5,698.5]; % RH

% paths
addpath('./Clopema_Segmentation/libs/maxflow', './Clopema_Segmentation/gmm');

% load image and color model
img = imread(INPUT_IMG);
rgbModel = load(RGB_MODEL);

% run the segmentation
[ptsFull, segMask] = grabcut_segmentation(img, rgbModel, RESIZE_FACTOR, ROI_COORDS);
[ tableMask ] = poly2mask(ROI_COORDS(1,:),ROI_COORDS(2,:), size(segMask,1), size(segMask,2));

mask = segMask + tableMask;

% show result
plot_img(2, 2, 1, img);
plot_img(2, 2, 2, mask/2);

% save image
imwrite(uint8(imresize(mask,[466,704],'nearest')), OUTPUT_IMG);
