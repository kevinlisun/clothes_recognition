function h = plot_cyclic(pts, varargin)

if size(pts, 2) > 0
    pts = [pts, pts(:,1)];
    h = plot(pts(1,:), pts(2,:), varargin{:});
end

end
