function [ W ] = dWdfic(y, f, pi, n, c, i)
    
% here y and f are n * c vectors
Y = reshape(y, [n c]);
F = reshape(f, [n c]);
Pi = reshape(pi, [n c]);

W = zeros(n*c, n*c);

for c1 = 1:c
    for c2 = 1:c
        if c1 == c2
            W((c1-1)*n+i, (c2-1)*n+i) = (1 - 2 * Pi(i,c1)) * (Pi(i,c1) - Pi(i,c1)^2);
        else
            W((c1-1)*n+i, (c2-1)*n+i) = -Pi(i,c1) * (Pi(i,c2) - Pi(i,c2)^2);
            %%W((c1-1)*n+i, (c2-1)*n+i) = 0;
        end
    end
end