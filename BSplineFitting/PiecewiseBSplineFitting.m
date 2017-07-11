function [ fit_obj ] = PiecewiseBSplineFitting( rangeMap, patchSize, knotVec, C )

%% divive range mape in patches
    uSize = patchSize(2); % patch height
    wSize = patchSize(1); % patch length
    
    uNum = fix( (size(rangeMap,1)-1)/uSize ) + 1;
    wNum = fix( (size(rangeMap,2)-1)/wSize ) + 1;
    
    Patch = cell(uNum,wNum);
    isnanMap = zeros(uNum,wNum);
    
    for i = 1:uNum
        for j = 1:wNum
            xi = (j-1)*wSize+1 : min(size(rangeMap,2),j*wSize);
            yi = (i-1)*uSize+1 : min(size(rangeMap,1),i*uSize);
            [ XI YI ] = meshgrid( xi, yi ); 
            Patch{i,j}(:,:,1) = XI;
            Patch{i,j}(:,:,2) = YI;
            Patch{i,j}(:,:,3) = rangeMap( (i-1)*uSize+1 : min(size(rangeMap,1),i*uSize) , (j-1)*wSize+1 : min(size(rangeMap,2),j*wSize));
            if sum(sum(isnan(Patch{i,j}(:,:,3)))) == uSize*wSize || sum(sum(isnan(Patch{i,j}(:,:,3))==0)) < 20
                isnanMap(i,j) = 1;
            end
        end
    end
%%
    count = 0;
%     h = waitbar(0,'Piecewise B-Spline Surface Fitting ...');

%% fit the surface in patches

    if nargin < 4
        [ C ] = ComputeUniformOpenBSplineBaseFun( knotVec, wSize, uSize );
    end
    
    for i = 1:uNum
        for j = 1:wNum
            if isnanMap(i,j) == 1 || size(Patch{i,j},1)~=uSize || size(Patch{i,j},2)~=wSize
                Model{i,j} = [];
            else
%                 waitbar(count/sum(sum(isnanMap==0)));
                [ obj ] = FitPatch( Patch{i,j}, knotVec, C );
                Model{i,j} = obj;
                count = count + 1;
            end
        end
    end
    fittedRangeMap = nan(size(rangeMap));

%     close(h);
    %%
    
    %% joint patches
    for i = 1:1:uNum-1
        for j = 1:1:wNum-1
            [ Model ] = Joint4PatchesWithC0( Model, [ i j ] );
            [ Model ] = Joint4PatchesWithC1( Model, [ i j ] );
        end
    end
    %%
    
    points = [];
    %% Render the surface from the model
    for i = 1:uNum
        for j = 1:wNum
            if isempty(Model{i,j})
%                 patch = rangeMap((i-1)*uSize+1:min(size(rangeMap,1),i*uSize),(j-1)*wSize+1:min(size(rangeMap,2),j*wSize));
%                 patch(:,:) = nan;
                patch = Patch{i,j}(:,:,3);
            else
                obj = Model{i,j};
                D = obj.C * obj.B;
                points = [ points; D ];
% % %                 xi = (j-1)*wSize+1 : min(size(rangeMap,2),j*wSize);
% % %                 yi = (i-1)*uSize+1 : min(size(rangeMap,1),i*uSize);
% % %                 [ XI YI ] = meshgrid( xi, yi );
% % %                 patch = griddata( D(:,1), D(:,2), D(:,3), XI, YI, 'linear' );
                patch = reshape(D(:,3),[uSize wSize]);
                if obj.isnan
                    patch(obj.nanMap) = nan;
                end
            end
            fittedRangeMap((i-1)*uSize+1:min(size(rangeMap,1),i*uSize),(j-1)*wSize+1:min(size(rangeMap,2),j*wSize)) = patch;
        end
    end
    
    fit_obj.rangeMap = fittedRangeMap;
    fit_obj.points = points;
    
    
    
    