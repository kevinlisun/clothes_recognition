function [ W ] = validW(y, f, pi, n, c)
    
% here y and f are n * c vectors
Y = reshape(y, [n c]);
F = reshape(f, [n c]);
Pi = reshape(pi, [n c]);

W = zeros(n*c, n*c);

for c1 = 1:c
    for i = 1:n
        for c2 = 1:c
            for j = 1:n
                if i == j
                    if c1 == c2
                        W((c1-1)*n+i, (c2-1)*n+j) = Pi(i,c1) - Pi(i,c1)^2;
                    else
                        W((c1-1)*n+i, (c2-1)*n+j) = - Pi(i,c1) * Pi(i,c2);
                    end
                end
            end
        end
    end
end
                  
    