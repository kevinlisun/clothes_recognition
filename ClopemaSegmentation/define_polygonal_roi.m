close all;
clear;

% directory containing images
DATA_DIR = './data_cmp/';

% load all PNG images from the directory
dirFiles = dir(strcat(DATA_DIR, '*.png'));

% define polygonal regions of interest for all images
for i = 1:numel(dirFiles)
    file = dirFiles(i);
    img = imread(strcat(DATA_DIR, file.name));
    [~, x, y] = roipoly(img);
    polyRoi = [x y]';
    save(strcat(DATA_DIR, file.name(1:end-4), '.mat'), 'polyRoi');
end
