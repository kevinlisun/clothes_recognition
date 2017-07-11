function [segBound, segMask] = grabcut_segmentation(...
    img, rgbModel, resizeFactor, roiPoly)

% plot settings
PLOT_FIG = false;
PLOT_TIKZ = false;
FROW = 2;
FCOL = 3;

% resize image
img = double(img) / 255;
img = imresize(img, resizeFactor, 'bicubic');
img(img > 1) = 1;
img(img < 0) = 0;
[h, w, ~] = size(img);
hw = h * w;

% extract RGB values for all pixels
rgb = reshape(img, hw, 3)';

% initialize garment and table mask
[indGar, indTab] = init_seg_mask_gmm(rgb, ...
    rgbModel.Prior, rgbModel.Mean, rgbModel.Cov, ...
    rgbModel.threshGar, rgbModel.threshTab);

% build indices containing outer part of image
if exist('roiPoly', 'var') && size(roiPoly, 1) == 2 && size(roiPoly, 2) >= 3
    roiPoly = roiPoly * resizeFactor;
    roiMask = roipoly(img, roiPoly(1,:), roiPoly(2,:));
    indOut = find(roiMask == 0);
else
    B = 1;
    indOut = rect2ind(w, h, B, B, w-B, h-B, 'out')';
end

% remove outer pixels from garment and table mask
indGar = setdiff(indGar, indOut);
indTab = setdiff(indTab, indOut);

% plot initialization mask for grabcut
if PLOT_FIG
    plot_mask(FROW, FCOL, 1, img, indGar, indTab, indOut);
end

% run grabcut
[matGar, matTab] = grabcut(img, [], indOut, indGar, indTab);

% plot resulting segmentation mask found by grabcut
if PLOT_FIG
    plot_mask(FROW, FCOL, 2, img, matGar, matTab);
end

% trace boundary of segmentation
if numel(matGar) > 0
    segBound = segmentation_boundary(h, w, matGar);
    segBound = [segBound(:,2), segBound(:,1)]';
    segBound = segBound / resizeFactor;
    [~, segBound] = poly_pos_orient(segBound);
else
    segBound = zeros(2, 0);
end

if PLOT_TIKZ
    indUnknown = setdiff(1:hw, [indGar indTab]);
    plot_mask(FROW, FCOL, 3, img, indGar, indTab, indUnknown);
    hold on;
    plot_cyclic(segBound * resizeFactor, 'Color', [0.8 0 0], 'LineWidth', 1);
    hold on;
    set(gca, 'Visible', 'off');
    set(gca, 'YDir', 'reverse');
    fig2tikz('fig/jeansSeg.tikz', 'w');
end

% create segmentation mask
segMask = zeros(h / resizeFactor, w / resizeFactor);
segMask = roipoly(segMask, segBound(1,:), segBound(2,:));

end
