function [ Patch isnanMap ] = Divide2Patches( rangeMap, patchSize )

    uSize = patchSize(2); % patch height
    wSize = patchSize(1); % patch length
    
    uNum = fix( size(rangeMap,1)/uSize ) + 1;
    wNum = fix( size(rangeMap,2)/wSize ) + 1;
    
    Patch = cell(uNum,wNum);
    isnanMap = zeros(uNum,wNum);
    
    for i = 1:uNum
        for j = 1:wNum
            Patch{i,j} = rangeMap((i-1)*uSize+1:min(size(rangeMap,1),i*uSize),(i-1)*wSize+1:min(size(rangeMap,2),i*wSize));
            if sum(sum(isnan(Patch{i,j}))) == uSize*wSize;
                isnanMap = 1;
            end
        end
    end
    
    
    
% %      uNum = fix( (size(rangeMap,1)-1)/(uSize-1) ) + 1;
% %     wNum = fix( (size(rangeMap,2)-1)/(wSize-1) ) + 1;
% %     
% %     Patch = cell(uNum,wNum);
% %     
% %     for i = 1:uNum
% %         for j = 1:wNum
% %             Patch{i,j} = rangeMap((i-1)*(uSize-1)+1:min(size(rangeMap,1),i*(uSize-1)+1),(i-1)*(wSize-1)+1:min(size(rangeMap,2),i*(wSize-1)+1));
% %         end
% %     end
    
            