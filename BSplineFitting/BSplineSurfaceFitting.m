function [ fittedRangeMap ] = BSplineSurfaceFitting( rangeMap, para )
    
    patchSize = para.patchSize;
    knotVec = para.knotVec;
    ntimes = para.ntimes;
    mask = para.mask;
    % only fit the clothes region
    rangeMap(~mask) = NaN;
    
    fittedRangeMap = zeros(size(rangeMap,1),size(rangeMap,2),ntimes);
    move = round(patchSize(1)/ntimes);
    
    uSize = patchSize(2); % patch height
    wSize = patchSize(1); % patch length
    [ C ] = ComputeUniformOpenBSplineBaseFun( knotVec, wSize, uSize );
    
    fittedRangeMap = nan(size(rangeMap,1),size(rangeMap,2),ntimes);
    
    parfor i = 1:ntimes
        rangeMapi = rangeMap;
        if i == 1
            upperRest = [];
            leftRest = [];
        else
            upperRest = rangeMapi(1:(i-1)*move,:);
            rangeMapi(1:(i-1)*move,:) = [];
            leftRest = rangeMapi(:,1:(i-1)*move);
            rangeMapi(:,1:(i-1)*move) = [];
        end
        [ obj_i ] = PiecewiseBSplineFitting( rangeMapi, patchSize, knotVec, C );
        rangeMapi = obj_i.rangeMap;
        rangeMapi = [ leftRest, rangeMapi ];
        rangeMapi = [ upperRest; rangeMapi ];
        fittedRangeMap(:,:,i) = rangeMapi;
    end
    
    fittedRangeMap = mean(fittedRangeMap,3);
        