function invK = invBlockDiag(K, c)

    invK = cell(c,1);
    
    index_row = 1;
    index_col = 1;
    row = size(K,1) / c;
    col = size(K,2) / c;
    
    for i = 1:c
        Ki = K(index_row:index_row+row-1, index_col:index_col+col-1);
        
        if i >= 2 && sum(sum(Ki==K(1:row,1:col))) == row*col
            invK{i} = invK{1};
        else
            invK{i} = inv(Ki);
        end
        index_row = index_row + row;
        index_col = index_col + col;
    end
    
    [invK] = constructBlockDiag(invK);
        

