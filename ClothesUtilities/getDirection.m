function [ move ] = getDirection( patch )

    center = [ round(0.5*(size(patch,1)+1)), round(0.5*(size(patch,1)+1)) ];
    diff = ones(size(patch))*patch(center(1),center(2)) - patch;
    [ tempMax a ] = max( diff );
    [ tempMaxmax b ] = max( tempMax );
    
    indexMax = [ a(b) b ];
    
    if indexMax == [1 1]
        move = [-1 -1];
    elseif indexMax == [2 1]
        move = [0 -1];
    elseif indexMax == [3 1]
        move = [1 -1];
    elseif indexMax == [3 2]
        move = [1 0];
    elseif indexMax == [3 3]
        move = [1 1];
    elseif indexMax == [2 3]
        move = [0 1];
    elseif indexMax == [1 3]
        move = [-1 1];
    elseif indexMax == [1 2]
        move = [-1 0];
    else
        move = [0 0];
    end
    
%     theta = atan(-(indexMax(1)-center(1))/((indexMax(2)-center(2)))) / pi * 180;
%     
%     if theta>=-22.5 && theta<22.5
%         move = [0 1];
%     elseif theta>=22.5 && theta<67.5
%         move = [-1 1];
%     elseif theta>=67.5 && theta<112.5
%         move = [-1 0];
%     elseif theta>=112.5 && theta<157.5
%         move = [-1 -1];
%     elseif theta>=157.5 && theta<-157.5
%         move = [0 -1];
%     elseif theta>=-157.5 && theta<-112.5
%         move = [1 -1];
%     elseif theta>=-112.5 && theta<-67.5
%         move = [1 0];
%     elseif theta>=-67.5 && theta<-22.5
%         move = [1 1];
%     else
%         move = [0 0];
%     end
    
