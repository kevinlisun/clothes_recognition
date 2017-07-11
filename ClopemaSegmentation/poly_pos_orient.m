function [posOrient, pts] = poly_pos_orient(pts)

n = size(pts, 2);

% initialize x1(i) = x(i+1) = p(1,i+1) and y1(i) = y(i+1) = p(2,i+1)
x = pts(1,:);
x1 = [x(2:n), x(1)];
y = pts(2,:);
y1 = [y(2:n), y(1)];

% compute signed area of the polygon
signedArea = sum(x .* y1 - x1 .* y);

% the area is positive for anti-clockwise and negative for clockwise
posOrient = (signedArea >= 0);

% make the polygon going clockwise while starting with the same point
if ~posOrient
    rev = [1, n:-1:2];
    pts = pts(:,rev);
end

end
