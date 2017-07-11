function [ C ] = ComputeUniformOpenBSplineBaseFun( knotVec, r, s )


    knotVec = knotVec./max(knotVec);
    order = sum(knotVec==0);
    n = length(knotVec)-order;
    m = length(knotVec)-order;

    % compute base function C
    u = zeros(r,s);
        w = zeros(r,s);
        
        u(1,:) = 0;
        
        for i = 1:s
            for j = 2:r
                u(j,i) = (j-1)/r;
            end
        end
        
        w(:,1) = 0;
        
        for i = 1:r
%             lower = chordLength( patch(i,:), s );
            for j = 2:s
%                 upper = chordLength( patch(i,:), j );
%                 w(i,j) = upper/lower;
                w(i,j) = (j-1)/s;
            end
        end
        
        
        C = zeros(r*s,n*m);
        
        for i = 1:r
            for j = 1:s
                for p = 1:n
                    for q = 1:m
                        C(((i-1)*s+j),((p-1)*m+q)) = ComputeBasisFunction( knotVec, order, p, u(i,j) ) * ComputeBasisFunction( knotVec, order, q, w(i,j) );
                    end
                end
            end
        end