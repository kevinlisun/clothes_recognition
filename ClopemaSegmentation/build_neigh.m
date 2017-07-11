function [n, d] = build_neigh(h, w, neigh_type)

% right
r1 = (1:(h*(w-1)))';
r2 = ((h+1):(h*w))';

% bottom
b1 = (1:(h*w))';
b1 = b1(mod(b1, h) ~= 0);
b2 = b1 + 1;

% join 4-neighborhood
n = [r1 r2; b1 b2];

% pixels in 4-neighborhood have distance 1
d = ones(1, size(n,1));

if neigh_type == 8
    
    % top-right
    tr1 = r1(mod(r1, h) ~= 1);
    tr2 = tr1 + (h - 1);
    
    % bottom-right
    br1 = b1(1:(end-h+1));
    br2 = br1 + (h + 1);
    
    % join 8-neighborhood
    n = [n; tr1 tr2; br1 br2];
    
    % pixels in 8-neighborhood have distance sqrt(2)
    dn = size(n, 1) - size(d, 2);
    d = [d, sqrt(2) * ones(1, dn)];
    
end

end
