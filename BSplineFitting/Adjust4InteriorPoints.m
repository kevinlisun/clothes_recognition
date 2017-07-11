function [ patchNW patchNE patchSW patchSE ] = Adjust4InteriorPoints( patchNW, patchNE, patchSW, patchSE )


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
    
    twistVec = zeros(1,1,3);
    
    if isempty(patchNW) == 0
        % adjust the center point
        n = patchNW.bnum_u;
        m = patchNW.bnum_w;
        % computer twist vector
        B_NW(:,:,1) = reshape(patchNW.B(:,1),[patchNW.bnum_u,patchNW.bnum_w]);
        B_NW(:,:,2) = reshape(patchNW.B(:,2),[patchNW.bnum_u,patchNW.bnum_w]);
        B_NW(:,:,3) = reshape(patchNW.B(:,3),[patchNW.bnum_u,patchNW.bnum_w]);
        twistVec_NW = 9*(B_NW(n,m,:)-B_NW(n-1,m,:)-B_NW(n,m-1,:)+B_NW(n-1,m-1,:));
        twistVec = twistVec + twistVec_NW;
    end
    if isempty(patchNE) == 0
        n = patchNE.bnum_u;
        m = patchNE.bnum_w;
        % computer twist vector
        B_NE(:,:,1) = reshape(patchNE.B(:,1),[patchNE.bnum_u,patchNE.bnum_w]);
        B_NE(:,:,2) = reshape(patchNE.B(:,2),[patchNE.bnum_u,patchNE.bnum_w]);
        B_NE(:,:,3) = reshape(patchNE.B(:,3),[patchNE.bnum_u,patchNE.bnum_w]);
        twistVec_NE = 9*(B_NE(n,2,:)-B_NE(n-1,2,:)-B_NE(n,1,:)+B_NE(n-1,1,:));
        twistVec = twistVec + twistVec_NE;
    end
    if isempty(patchSW) == 0
        n = patchSW.bnum_u;
        m = patchSW.bnum_w;
        % computer twist vector
        B_SW(:,:,1) = reshape(patchSW.B(:,1),[patchSW.bnum_u,patchSW.bnum_w]);
        B_SW(:,:,2) = reshape(patchSW.B(:,2),[patchSW.bnum_u,patchSW.bnum_w]);
        B_SW(:,:,3) = reshape(patchSW.B(:,3),[patchSW.bnum_u,patchSW.bnum_w]);
        twistVec_SW = 9*(B_SW(2,m,:)-B_SW(1,m,:)-B_SW(2,m-1,:)+B_SW(1,m-1,:));
        twistVec = twistVec + twistVec_SW;
    end
    if isempty(patchSE) == 0
        n = patchSE.bnum_u;
        m = patchSE.bnum_w;
        % computer twist vector
        B_SE(:,:,1) = reshape(patchSE.B(:,1),[patchSE.bnum_u,patchSE.bnum_w]);
        B_SE(:,:,2) = reshape(patchSE.B(:,2),[patchSE.bnum_u,patchSE.bnum_w]);
        B_SE(:,:,3) = reshape(patchSE.B(:,3),[patchSE.bnum_u,patchSE.bnum_w]);
        twistVec_SE = 9*(B_SE(2,2,:)-B_SE(1,2,:)-B_SE(2,1,:)+B_SE(1,1,:));
        twistVec = twistVec + twistVec_SE;
    end
    
    % set 4 twist vectors equal to the average
    twistVec = twistVec / sum(emptyList);
    % twistVec = zeros(1,1,1);
    
    % modify interior points value using new twist vector
    if isempty(patchNW) == 0
        n = patchNW.bnum_u;
        m = patchNW.bnum_w;
        B_NW(n-1,m-1,:) = twistVec/9 + B_NW(n,m-1,:) + B_NW(n-1,m,:) - B_NW(n,m,:);
        patchNW.B(:,1) = reshape(B_NW(:,:,1),[n*m,1]);
        patchNW.B(:,2) = reshape(B_NW(:,:,2),[n*m,1]);
        patchNW.B(:,3) = reshape(B_NW(:,:,3),[n*m,1]);
    end
    if isempty(patchNE) == 0
        n = patchNE.bnum_u;
        m = patchNE.bnum_w;
        B_NE(n-1,2,:) = -twistVec/9 + B_NE(n,2,:) + B_NE(n-1,1,:) - B_NE(n,1,:);
        patchNE.B(:,1) = reshape(B_NE(:,:,1),[n*m,1]);
        patchNE.B(:,2) = reshape(B_NE(:,:,2),[n*m,1]);
        patchNE.B(:,3) = reshape(B_NE(:,:,3),[n*m,1]);
    end
    if isempty(patchSW) == 0
        m = patchSW.bnum_w;
        n = patchSW.bnum_u;
        B_SW(2,m-1,:) = -twistVec/9 + B_SW(1,m-1,:) + B_SW(2,m,:) - B_SW(1,m,:);
        patchSW.B(:,1) = reshape(B_SW(:,:,1),[n*m,1]);
        patchSW.B(:,2) = reshape(B_SW(:,:,2),[n*m,1]);
        patchSW.B(:,3) = reshape(B_SW(:,:,3),[n*m,1]);
    end
    if isempty(patchSE) == 0
        m = patchSE.bnum_w;
        n = patchSE.bnum_u;
        B_SE(2,2,:) = twistVec/9 + B_SE(1,2,:) + B_SE(2,1,:) - B_SE(1,1,:);
        patchSE.B(:,1) = reshape(B_SE(:,:,1),[n*m,1]);
        patchSE.B(:,2) = reshape(B_SE(:,:,2),[n*m,1]);
        patchSE.B(:,3) = reshape(B_SE(:,:,3),[n*m,1]);
    end
        
    
        
    
        