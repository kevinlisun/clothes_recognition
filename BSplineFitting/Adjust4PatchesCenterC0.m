function [ patchNW patchNE patchSW patchSE ] = Adjust4PatchesCenterC0( patchNW, patchNE, patchSW, patchSE )


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
    
    if sum(emptyList) <= 1
        return;
    end
    
    center = zeros(1,3);
    
    if isempty(patchNW) == 0
        % adjust the center point
        n = patchNW.bnum_u;
        m = patchNW.bnum_w;
        center = center + patchNW.B(end,:);
    end
    if isempty(patchNE) == 0
        n = patchNE.bnum_u;
        m = patchNE.bnum_w;
        center = center + patchNE.B(n,:);
    end
    if isempty(patchSW) == 0
        n = patchSW.bnum_u;
        m = patchSW.bnum_w;
        center = center + patchSW.B(end-n+1,:);
    end
    if isempty(patchSE) == 0
        n = patchSE.bnum_u;
        m = patchSE.bnum_w;
        center = center + patchSE.B(1,:);
    end
    
    % set center control point as the average
    center = center / sum(emptyList);
    
    % modify ceter point value
    if isempty(patchNW) == 0
        patchNW.B(end,:) = center;
    end
    if isempty(patchNE) == 0
        n = patchNE.bnum_u;
        patchNE.B(n,:) = center;
    end
    if isempty(patchSW) == 0
        n = patchSW.bnum_u;
        patchSW.B(end-n+1,:) = center;
    end
    if isempty(patchSE) == 0
        n = patchSE.bnum_u;
        patchSE.B(1,:) = center;
    end

    
        