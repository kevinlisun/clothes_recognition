function order = plot_img(rows, cols, order, img)

% handle grayscale images as RGB images with all 3 components equal
if size(img, 3) == 1
    img = repmat(img, [1 1 3]);
end

% ensure cyclic order in range 1..rows*cols
cyclicOrder = 1 + mod(order - 1, rows * cols);

% plot image
subfig(rows, cols, cyclicOrder);
image(img);
axis image;

% update order
order = order + 1;

end
