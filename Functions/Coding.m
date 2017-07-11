function [ code ] = Coding( descriptors, code_book, is_norm )

    [ distMat ] = ComputeDistance( descriptors, code_book );
    
    [ a b ] = min( distMat, [], 2 );
    
    code = zeros( size(distMat) );
    
    for i = 1:length(a)
        code(i,b(i)) = 1;
    end
    
    code = sum(code,1);
    
    if is_norm
        code = code ./ sum(code);
    end
    