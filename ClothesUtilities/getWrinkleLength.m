function length = getWrinkleLength( wrinklei, rangeMap, pcl )

    points2D = wrinklei.fittedPoints;
    
    points3D = zeros(size(points2D,1),3);
    length = 0;
  
    for i = 1:size(points2D,1)
        points3D(i,:) = points2Dto3D( points2D(i,:), size(rangeMap), pcl );
        if i > 1 && isnan(ComputeDistance( points3D(i-1,:), points3D(i,:) )) == 0
            length = length + ComputeDistance( points3D(i-1,:), points3D(i,:) );
        end
    end
    
    length = length * 1000;
    
    if isnan(length) + isempty(length) > 0
        length = 0;
    end