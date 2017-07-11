function [ patchNW patchNE patchSW patchSE ] = Adjust4PatchesCenterC1( patchNW, patchNE, patchSW, patchSE )


    %    |------> w
    %    |        m col
    %    |
    %    |
    %    V u
    %      n row
    
    
    emptyList(1) = ~isempty(patchNW);
    emptyList(2) = ~isempty(patchNE);
    emptyList(3) = ~isempty(patchSW);
    emptyList(4) = ~isempty(patchSE);
    
    if sum(emptyList) < 4
        return;
    end
    
    % set center control point as the average of 4 cross points
    n = patchNW.bnum_u;

    center = (patchNW.B(end-1,:)+patchNE.B(2*n,:)+patchSW.B(end-2*n+1,:)+patchSE.B(2,:))/4;
    patchNW.B(end,:) = center;
    patchNE.B(n,:) = center;
    patchSW.B(end-n+1,:) = center;
    patchSE.B(1,:) = center;
    
    
        