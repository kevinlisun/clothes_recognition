function height = getWrinkleHeight( wrinklei, rangeMap, pcl )

    height = 0;
    count = 0;
    
    triplets = wrinklei.triplet(wrinklei.istriplet==2);
    
    if length(triplets) == 0
        return;
    end
    
    for i = 1:size(triplets,1)
        
        center2D = wrinklei.triplet(i).center;
% %         leftChild = wrinklei.triplet(i).leftChild;
% %         rightChild = wrinklei.triplet(i).rightChild;
        
        if isnan( rangeMap(center2D(2),center2D(1)) ) == 0
            % %             if numel(leftChild)*numel(rightChild) == 0
            % %                 continue;
            % %             end
            % %             heighti = rangeMap(center2D(2),center2D(1)) - 0.5*(rangeMap(leftChild(2),leftChild(1))+rangeMap(rightChild(2),rightChild(1)));
            % %             height = height + heighti;
            heighti = rangeMap(center2D(2),center2D(1));
            height = height + heighti;
            count = count + 1;
        end
    end
    
    height = height / count;
% % %     height = height * 1000;
    
