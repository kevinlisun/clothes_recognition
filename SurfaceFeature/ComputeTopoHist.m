function [ topohist ] = ComputeTopoHist( rangeMap, ridge, contour, bin )
    
    [ pY pX ] = find( ridge==1 );
    [ ridgeP ] = [ pX pY ];
    [ pY pX ] = find( contour==1 );
    [ contourP ] = [ pX pY ];
    
    [ distMat ] = ComputeDistance( ridgeP, contourP );
    [ distMin b ] = min(distMat,[],2);
    
    heigtMat = zeros(length(b),1);
    
    for i = 1:length(b)
        heigtMat(i,1) = rangeMap(ridgeP(i,2),ridgeP(i,1)) - rangeMap(contourP(b(i),2),contourP(b(i),1));
    end
    
    abandonList = distMin<5 | distMin>50 | heigtMat<5 | heigtMat>50;
    distMin(abandonList) = [];
    heigtMat(abandonList) = [];
    
    inx1 = vl_binsearch(bin{1},distMin);
    inx2 = vl_binsearch(bin{2},heigtMat);
    
    for i = 1:length(bin{1})
        for j = 1:length(bin{2})
            bi_dim_ist(i,j) = sum(inx1==i&inx2==j);
        end
    end
    
    topohist = bi_dim_ist(:)';
    
% %     topohist = vl_binsum( zeros(1,length(bin{1})),  1, inx1 );
    
    