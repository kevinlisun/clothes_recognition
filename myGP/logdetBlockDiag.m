function logdet = logdetBlockDiag(K, w, c)
    
    index_row = 1;
    index_col = 1;
    row = size(K,1) / c;
    col = size(K,2) / c;
    
    logdet = 0;
    
    for i = 1:c
        Ki = K(index_row:index_row+row-1, index_col:index_col+col-1);
        wi = w(index_col:index_col+col-1);
  
        logdeti = logdetA(Ki, wi);
        logdet = logdet + logdeti;
        
        index_row = index_row + row;
        index_col = index_col + col;
    end

