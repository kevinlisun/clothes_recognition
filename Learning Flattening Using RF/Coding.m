function [ code ] = Coding( descriptors, code_book )

    [ distMat ] = ComputeDistance( descriptors, code_book );
    
    [ a b] = min( distMat, [], 2 );
    
    code = zeros( size(distMat) );
    
    for i = 1:length(a)
        code(i,b(i)) = 1;
    end
    
    code = sum(code,1);
    