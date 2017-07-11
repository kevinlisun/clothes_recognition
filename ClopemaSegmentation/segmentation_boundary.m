function boundary = segmentation_boundary(h, w, segInd)

% build binary image defining segmentation
segImg = zeros(h, w);
segImg(segInd) = 1;

% trace border
boundary = bwboundaries(segImg, 8, 'noholes');
boundary = boundary{1};

end
