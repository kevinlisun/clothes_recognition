function subimg = create_subimg(img, subind, background)

% color settings
TILE_SIZE = 20;
CHESS_COLOR_1 = 0.85;
CHESS_COLOR_2 = 0.95;
SOLID_COLOR = 0.9;

% get image size
[h, w, ~] = size(img);

if exist('background', 'var') && ischar(background) && strcmp(background, 'chessboard')
    
    % create chessboard backgroung
    subimg = CHESS_COLOR_1 * ones(h, w, 3);
    for i = 1:ceil(h/TILE_SIZE)
        rng_i = (i*TILE_SIZE-TILE_SIZE+1):min(h,i*TILE_SIZE);
        for j = 1:ceil(w/TILE_SIZE)
            rng_j = (j*TILE_SIZE-TILE_SIZE+1):min(w,j*TILE_SIZE);
            if mod(i+j, 2) == 0
                sub_ij = allcomb(rng_i, rng_j);
                ind_ij = sub2ind([h, w], sub_ij(:,1), sub_ij(:,2));
                ind3_ij = index3(h, w, ind_ij);
                subimg(ind3_ij) = CHESS_COLOR_2;
            end
        end
    end
    
else
    
    % initialize background color triple
    if ~exist('background', 'var'), color = SOLID_COLOR; end
    if numel(color) == 1, color = [color color color]; end
    
    % create solid background
    subimg = zeros(h, w, 3);
    for c = 1:3
        subimg(:,:,c) = color(c);
    end
    
end

% fill by suibindexed image pixels
subidx3 = index3(h, w, subind);
subimg(subidx3) = img(subidx3);

end
