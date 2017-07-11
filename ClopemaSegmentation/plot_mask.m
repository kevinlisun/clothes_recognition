function order = plot_mask(rows, cols, order, img, varargin)

IMG_MASK = true;
S = 1; D = 1;
CMAP = [S 0 0; 0 S 0; 0 0 S; D D 0; D 0 D; 0 D D];
IMG_ALPHA = 0.5;

[h, w, ~] = size(img);
nInd = length(varargin);

if IMG_MASK
    % build a mask on a top of image
    mask = img;
    for i = 1:nInd
        for c = 1:3
            ind_c = varargin{i} + (c - 1) * h * w;
            mask(ind_c) = IMG_ALPHA * mask(ind_c) + (1 - IMG_ALPHA) * CMAP(i, c);
        end
    end
else
    % create gray-scale mask
    mask = zeros(h, w);
    for i = 1:nInd
        mask(varargin{i}) = i / nInd;
    end
end

% plot it
plot_img(rows, cols, order, mask);

end
