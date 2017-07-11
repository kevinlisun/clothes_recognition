function h = plot3_plane(x, y, z)

% normalize x and y values
x = round(x - min(x)) + 1;
y = round(y - min(y)) + 1;

% size of the output image
w = max(x);
h = max(y);

% indices of the xy coordinates
ind = sub2ind([h w], y, x);

% build indices of colors
cmap = colormap;
crng = size(cmap, 1);
cind = round(normalize(z, 1, crng));

% build image
img = ones(h, w, 3);
for c = 1:3
    img((c - 1) * h * w + ind) = cmap(cind,c);
end

% plot it
image(img);
colorbar;
axis image;

end
