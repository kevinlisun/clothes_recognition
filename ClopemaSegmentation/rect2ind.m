function ind = rect2ind(w, h, x1, y1, x2, y2, inOut)

dx = x2 - x1 + 1;
dy = y2 - y1 + 1;

if (dx > 0) && (dy > 0)
    if ~exist('inOut', 'var') || strcmp(inOut, 'in')
        sx = ((x1-1)*h):(h):((x2-1)*h);
        Sx = repmat(sx, dy, 1);

        sy = y1:y2;
        Sy = repmat(sy', 1, dx);
        
        ind = reshape(Sx + Sy, dy * dx, 1);
    else
        indL = 1:((x1-1)*h);
        indR = (x2*h+1):(h*w);
        
        indT = rect2ind(w, h, x1, 1, x2, y1 - 1);
        indB = rect2ind(w, h, x1, y2 + 1, x2, h);
        
        ind = [indL'; indT; indB; indR'];
    end
else
    % rectangle has not a positive size
    ind = [];
end

end
