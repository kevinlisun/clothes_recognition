function [ Nik ] = ComputeBasisFunction( x, k, index, t )

    % k for order, means degree k -1 
    % x is knot vectors
    % n+1 is the number of control plogyon
    % t for parameter t
    
    for i = 1:length(x)-1
        if t>=x(i) && t<x(i+1)
            Ni1(i) = 1;
        else
            Ni1(i) = 0;
        end
    end
    
    if sum(Ni1)==0
        Ni1(end-k+1) = 1;
    end
    
%     x = x(index:index+k)
    Ni1 = Ni1(index:index+k-1);
    
    N = zeros(k,k);
    N(1,:) = Ni1;
    
    for j = 2:k
        for i = 1:k-j+1
            Nij_left = (t-x(i+index-1))*N(j-1,i)/(x(i+j+index-2)-x(i+index-1));
            Nij_right = (x(i+j+index-1)-t)*N(j-1,i+1)/(x(i+j+index-1)-x(i+1+index-1));
            if isnan(Nij_left)==1
                Nij_left = 0;
            end
            if isnan(Nij_right)==1
                Nij_right = 0;
            end
            N(j,i) = Nij_left + Nij_right;
        end
    end
    
    Nik = N(k,1);
    
    
            
% %     n = length(x)-k;
% %     N = zeros(k,k);
% %     
% %     for i = 1:k
% %         if t>=x(index+i-1) && t<x(index+i)
% %             N(1,i) = 1;
% %         else
% %             N(1,i) = 0;
% %         end
% %     end
% %     
% %     for i = 2:k
% %         for j = 1:k-i+1
% %             Nij_left = (t-x(index+j-1))*N(j,i-1)/(x(index+j+k-2)-x(index+j-1));
% %             Nij_right = (x(index+j+k-1)-t)*N(j+1,i-1)/(x(index+j+k-1)-x(index+j));
% %             if isnan(Nij_left)==1
% %                 Nij_left = 0;
% %             end
% %             if isnan(Nij_right)==1
% %                 Nij_right = 0;
% %             end
% %             N(i,j) = Nij_left + Nij_right;
% %         end
% %     end
% %     
% %     Nik = N(k,1);
% %     
% %     
% %     
    
    
    
%     for i = 1:n+k-1
%         if t>=x(i) && t<x(i+1)
%             N(i,1) = 1;
%         else
%             N(i,1) = 0;
%         end
%     end
%     
%     for j = 2:k
%         for i = 1:n+1
%             Nij_left = (t-x(i))*N(i,j-1)/(x(i+j-1)-x(i)); 
%             Nij_right = (x(i+j)-t)*N(i+1,j-1)/(x(i+j)-x(i+1));
%             if isnan(Nij_left)==1
%                 Nij_left = 0;
%             end
%             if isnan(Nij_right)==1
%                 Nij_right = 0;
%             end
%             N(i,j) = Nij_left + Nij_right;
%         end
%     end
%     
%     Nik = N(Index,k);
    
    
    
    
    
    
    
    