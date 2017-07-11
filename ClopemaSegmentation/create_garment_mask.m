function mask = create_garment_mask(annot, h, w, border)

% default border
if ~exist('border', 'var')
    border = 0;
end

% initialize table mask to have the same size as the image
mask = zeros(h, w);

% annotated vertices
verts = annot.poly_c;
nodeNames = char([annot.node_names{:}]);

% plot convex hull or polygon
% mask = plot_convex_hull(verts, mask);
mask = plot_polygon(verts, nodeNames, mask);

% inflate or deflate the mask by the specified border
if border > 0
    disk = strel('disk', border);
    mask = imdilate(mask, disk);
elseif border < 0
    disk = strel('disk', -border);
    mask = imerode(mask, disk);
end

end


function mask = plot_segment(vi, vj, mask)

% ensure dense enough sequence of points forming segment
ptsCount = 2 * ceil(norm(vi - vj));

% coordinates of segment points
x = round(linspace(vi(1), vj(1), ptsCount));
y = round(linspace(vi(2), vj(2), ptsCount));

% remove outliers
[h, w] = size(mask);
in = (1 <= x) & (x <= w) & (1 <= y) & (y <= h);
x = x(in);
y = y(in);

% convert coordinates to indices and plot them to mask
ind = sub2ind(size(mask), y, x);
mask(ind) = 1;

end


function mask = plot_convex_hull(verts, mask)

% plot the annotated vertices on
for i = 1:size(verts,1)
    x = round(verts(i,1));
    y = round(verts(i,2));
    mask(y,x) = 1;
end

% plot their convex hull
mask = bwconvhull(mask, 'union');

end


function mask = plot_polygon(verts, nodeNames, mask)

mVerts = size(verts, 1);

% plot polygon by connecting annotated vertices
for i = 1:mVerts
    j = i + 1;
    if j > mVerts, j = 1; end
    mask = plot_segment(verts(i,:), verts(j,:), mask);
end

% plot folding segments
for fold = 1:mVerts
    foldName = strcat('fold_', int2str(fold));
    foldInd = strmatch(foldName, nodeNames);
    if length(foldInd) == 2
        vi = verts(foldInd(1),:);
        vj = verts(foldInd(2),:);
        mask = plot_segment(vi, vj, mask);
    else
        break;
    end
end

% fill the polygons
mask = imfill(mask, 4, 'holes');

end
