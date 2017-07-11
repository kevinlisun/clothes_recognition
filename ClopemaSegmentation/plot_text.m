function plot_text(pos, txt, placement, varargin)

offset = 0.02 * sqrt(sum((max(pos,[],2) - min(pos,[],2)).^2));
offsetX = 0;
offsetY = 0;

switch placement
    case 'North'
        offsetY = offset;
    case 'South'
        offsetY = -offset;
    case 'East'
        offsetX = offset;
    case 'West'
        offsetX = -offset;
end

for i = 1:numel(txt)
    x = pos(1,i) + offsetX;
    y = pos(2,i) + offsetY;
    text(x, y, txt{i}, varargin{:});
end

end
