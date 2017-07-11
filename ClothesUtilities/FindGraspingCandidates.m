function [ rankedGraspingCandidates ] = FindGraspingCandidates( fittedRangeMap, realRange, shapeIndex, ridge, contour, mode )


    %% compute H,K,k1,k2,S
    [fx,fy] = gradient(fittedRangeMap);
    [fxx, fxy] = gradient(fx);
    [fyx, fyy] = gradient(fy);
    
    H = ( (1+fy.^2).*fxx + (1+fx.^2).*fyy - 2.*fx.*fy.*fxy ) ./ ( 2*((sqrt(ones(size(fx))+fx.^2+fy.^2)).^3) );
    K = ( fxx.*fyy - fxy.^2 ) ./ ( ( ones(size(fx)) + fx.^2 + fy.^2 ).^2 );
    
    kmax = H + sqrt(H.^2.-K);
    
    [fx,fy] = gradient(kmax);
    theta = atan(fy./fx);
    
    [ rRow rCol ] = find( ridge == 1 );
    
    % dilate shape index 7 region by 1
    tempMap = shapeIndex==7;
    se = strel('disk', 1, 0);
    tempMap = imdilate(tempMap,se);
    shapeIndex(tempMap==1) = 7;
    
    thres = 50;
    
    candidate_map = zeros( size(realRange) );
    candidate_map_coords = zeros(length(rRow), 2);
    
    for i = 1:length(rRow)
        [ obj, isT ] = SearchingTriplets( fittedRangeMap, realRange, shapeIndex, contour, [rRow(i) rCol(i)], theta(rRow(i),rCol(i)), thres );
        candidate{i,1} = obj;
        isTriplets(i,1) = isT;
        coord = [obj.center(1), obj.center(2)];
        candidate_map_coords(i,:) = coord;
    end
    for i = 1:length(rRow)
        coord = candidate_map_coords(i,:);
        candidate_map(coord(1),coord(2)) = 1;
    end
    
    graspingCandidates = candidate(isTriplets==2);
    
    % remove isolated candidates
    r = 5;
    isolated_candidates = zeros(length(graspingCandidates),1);
    
    candidate_score = zeros(length(graspingCandidates),2);
    
    for i = 1:length(graspingCandidates)
        obj = graspingCandidates{i};
        pos = obj.center;
        patch = candidate_map(max(1,pos(1)-r):min(size(realRange,1),pos(1)+r),max(1,pos(2)-r):min(size(realRange,2),pos(2)+r));
        if sum(sum(patch)) < r
            isolated_candidates(i) = 1;
        end

        candidate_score(i,1) = obj.height;
        
        if obj.height > 50
            candidate_score(i,2) = obj.abheight;
        else
            candidate_score(i,2) = 0;
        end
    end
    
    candidate_score(isolated_candidates==1,:) = 0;
    [ a b ] = sort( candidate_score, 'descend' );
    b = b';
    b = b(:);
    
    rankedGraspingCandidates = [];
    
    for i = 1:length(graspingCandidates)
        is_add = true;
        for j = 1:length(rankedGraspingCandidates)      
            if ComputeDistance(rankedGraspingCandidates{j}.position2D, graspingCandidates{b(i),1}.position2D) < 30
                is_add = false;
                break;
            end
        end
        if is_add
            rankedGraspingCandidates = [rankedGraspingCandidates; graspingCandidates(b(i),1)];
        end
    end
    
    rankedGraspingCandidates = [rankedGraspingCandidates; graspingCandidates];
    
    