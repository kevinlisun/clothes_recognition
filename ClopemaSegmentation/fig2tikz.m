function fig2tikz(name, widthHeight, varargin)

widthHeightArg = {};
if ~isempty(strfind(widthHeight, 'w'))
    widthHeightArg = {widthHeightArg{:}, 'width', '\figurewidth'};
end
if ~isempty(strfind(widthHeight, 'h'))
    widthHeightArg = {widthHeightArg{:}, 'height', '\figureheight'};
end

matlab2tikz(name, 'showInfo', false, ...
    widthHeightArg{:}, ...
    'extraTikzpictureOptions', 'font=\footnotesize', ...
    varargin{:});

end
