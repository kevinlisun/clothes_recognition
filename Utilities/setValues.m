function wPatch = setValues( wPatch, wPoints, val )

    sizeRow = size(wPatch,1);
    sizeCol = size(wPatch,2);
    
    row = wPoints(:,2);
    col = wPoints(:,1);
    
    for i = 1:length(row)
        if row(i)>0 & row(i)<=sizeRow & col(i)>0 &col(i)<=sizeCol
           wPatch(row(i),col(i)) = val;
        end
    end