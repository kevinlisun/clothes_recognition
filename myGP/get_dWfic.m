function [ dWfic ] = get_dWfic(W, pi, n, c, k, c3)

Pi = reshape(pi, [n c]);

dWfic = zeros(size(W));

i = k;
j = k;

for c1 = 1:c    
    for c2 = 1:c
        if c1 == c2
            if c3 == c1
                dWfic((c1-1)*n+i, (c2-1)*n+j) = (1-2*Pi(i,c1)) * (Pi(i,c1)-Pi(i,c1)^2);
            else %c3 != c1
                dWfic((c1-1)*n+i, (c2-1)*n+j) = (1-2*Pi(i,c1)) * (- Pi(i,c1)*Pi(k,c3));
            end
        else % c1 != c2
            if c1 == c3
                dWfic((c1-1)*n+i, (c2-1)*n+j) = - ( (Pi(i,c1)-Pi(i,c1)^2)*Pi(j,c2) + Pi(i,c1)*(-Pi(j,c2)*Pi(k,c3)) );
            elseif c2 == c3
                dWfic((c1-1)*n+i, (c2-1)*n+j) = - ( (-Pi(i,c1)*Pi(k,c3))*Pi(j,c2) + Pi(i,c1)*(Pi(j,c2)-Pi(j,c2)^2) );
            else %c1!=c2!=c3
                dWfic((c1-1)*n+i, (c2-1)*n+j) = - ( (-Pi(i,c1)*Pi(k,c3))*Pi(j,c2) + Pi(i,c1)*(-Pi(j,c2)*Pi(k,c3)) );
            end
        end
    end
end
    
    