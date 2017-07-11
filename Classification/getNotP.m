function [ notp ] = getNotP( p, label )

    notp = zeros(size(p));
    
    for i = 1:size(p,1)
        [ inx ] = find(label~=p(i)); 
        notp(i) = label(inx);
    end