function [indGar, indTab] = ...
    init_seg_mask_pca(rgb, transMat, threshGar, threshTab)

% transform RGB values using pre-trained transformation matrix
rgbTrans = transMat * [rgb; ones(1, size(rgb, 2))];
rgbTrans = rgbTrans(1:3,:);
dist = vecnorm(rgbTrans, 1);

% find garment pixels having big transformed RGB value and table
% pixels having low transformed RGB values
indGar = find(dist > threshGar);
indTab = find(dist < threshTab);

end
