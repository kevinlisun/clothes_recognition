function h = plot_rgb_cube(rgb, maxPoints, color)

% ensure that not too many points are plot
nRgb = size(rgb, 2);
if nRgb > maxPoints
    ind = randperm(nRgb, maxPoints);
    rgb = rgb(:,ind);
end

% if color is not specified then use the RGB values themselves
if ~exist('color', 'var')
    color = rgb';
end

h = scatter3(rgb(1,:), rgb(2,:), rgb(3,:), 10, color, 'filled');

axis equal;
grid on;
xlabel('red');
ylabel('green');
zlabel('blue');
view(40, 35);

end
