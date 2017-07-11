function [ ROS_INFO ] = graspingPoseEstamitation(graspingCandidates, ridgeMap, imresizeScale, PL, PR, dispMH, dispMV )

candidateNum = 5;

ROS_INFO_position3D_ROS = [];
ROS_INFO_gripperDir_ROS = [];
ROS_INFO_position2D_ROS = [];
ROS_INFO_normal_ROS = [];


count  = 0;
for ci = 1:length(graspingCandidates)
    
    if count >= candidateNum
        break;
    end
    
    if ci > 1
        distMat = ComputeDistance( ROS_INFO_position2D_ROS, graspingCandidates{ci,1}.position2D/imresizeScale );
        
        if min(min(distMat)) < 50/imresizeScale
            continue;
        end
    end
        
    position2D = graspingCandidates{ci,1}.position2D / imresizeScale; % Scale to original resolution
    
    thres = 20 / imresizeScale;
    thres2 = 0.10;
    
    INX = [];
    for i = 1:length(graspingCandidates)
        if ComputeDistance( graspingCandidates{1,1}.position2D, graspingCandidates{i,1}.position2D ) <= thres
            INX = [ INX; i ];
        end
    end
    
    if length(INX)==1
        position3D_ROS = get3Dpoint([position2D(1), position2D(2)], PL, PR, dispMH, dispMV);
        
        % get left child
        leftChild2D = graspingCandidates{1,1}.leftChild2D / imresizeScale;
        leftChild3D_ROS = get3Dpoint([leftChild2D(1), leftChild2D(2)], PL, PR, dispMH, dispMV);
        % get right child
        rightChild2D = graspingCandidates{1,1}.rightChild2D / imresizeScale;
        rightChild3D_ROS = get3Dpoint([rightChild2D(1), rightChild2D(2)], PL, PR, dispMH, dispMV);
        
        gripperDir = leftChild3D_ROS - rightChild3D_ROS;
        gripperDir_ROS = [ gripperDir(2), -1*gripperDir(1), gripperDir(3) ];
    else
        position3D_ROS = get3Dpoint([position2D(1), position2D(2)], PL, PR, dispMH, dispMV);
        position2D_ROS = position2D;
        
        for i = 1:length(INX)
            
            position2D = graspingCandidates{INX(i),1}.position2D / imresizeScale;
            Wrinkle_3D(i,:) = get3Dpoint([position2D(1), position2D(2)], PL, PR, dispMH, dispMV);
        end
        
        [ distMat ] = ComputeDistance(position3D_ROS, Wrinkle_3D);
        Wrinkle_3D = Wrinkle_3D(distMat < thres2, :);
        
        if size(Wrinkle_3D,1) < 5
            continue;
        end
        
        covMat = cov( Wrinkle_3D );
        [ V, D ] = eig( covMat );
        eigValue = diag( D );
        [ a b ] = max( eigValue );
        gripperDir_ROS = V(:,b)';
    end
    
    % get the grasping normal
    patchSize = 55 / imresizeScale;
    step = fix(1/imresizeScale);
    r = fix(patchSize/2);
    [PX PY] = meshgrid(position2D(1)-r:step:position2D(1)+r,position2D(2)-r:step:position2D(2)+r);
    PX = PX(:);
    PY = PY(:);
    
    % P3D is the 3D points of local neighbours of grasping point
    P3D = zeros(length(PX),3);
    
    for i = 1:length(PX)
        P3D(i,:) = get3Dpoint([PX(i), PY(i)], PL, PR, dispMH, dispMV);
    end
    % estimate normal via PCA, get the third largest eighen vector
    covMat = cov( P3D );
    [ V, D ] = eig( covMat );
    eigValue = diag( D );
    [ a b ] =min( eigValue );
    normal = V(:,b)';
    normal_ROS = normal./sqrt(sum(normal.^2));
    
    % output
    ROS_INFO_position3D_ROS = [ROS_INFO_position3D_ROS; position3D_ROS];
    ROS_INFO_gripperDir_ROS = [ROS_INFO_gripperDir_ROS; gripperDir_ROS];
    ROS_INFO_position2D_ROS = [ROS_INFO_position2D_ROS; position2D_ROS];
    ROS_INFO_normal_ROS = [ROS_INFO_normal_ROS;normal_ROS];
    count = count + 1;
    
end

if size(ROS_INFO_position3D_ROS,1) < 5
    rest = 5 - size(ROS_INFO_position3D_ROS,1);
    ROS_INFO_position3D_ROS = [ROS_INFO_position3D_ROS; ROS_INFO_position3D_ROS(1:rest,:)];
end
if size(ROS_INFO_gripperDir_ROS,1) < 5
    rest = 5 - size(ROS_INFO_gripperDir_ROS,1);
    ROS_INFO_gripperDir_ROS = [ROS_INFO_gripperDir_ROS; ROS_INFO_gripperDir_ROS(1:rest,:)];
end
if size(ROS_INFO_position2D_ROS,1) < 5
    rest = 5 - size(ROS_INFO_position2D_ROS,1);
    ROS_INFO_position2D_ROS = [ROS_INFO_position2D_ROS; ROS_INFO_position2D_ROS(1:rest,:)];
end
if size(ROS_INFO_normal_ROS,1) < 5
    rest = 5 - size(ROS_INFO_normal_ROS,1);
    ROS_INFO_normal_ROS = [ROS_INFO_normal_ROS; ROS_INFO_normal_ROS(1:rest,:)];
end

ROS_INFO.position3D_ROS = ROS_INFO_position3D_ROS;
ROS_INFO.gripperDir_ROS = ROS_INFO_gripperDir_ROS;
ROS_INFO.position2D_ROS = ROS_INFO_position2D_ROS;
ROS_INFO.normal_ROS = ROS_INFO_normal_ROS;





