function normal = GetPatchNormal( patch )


    center = [ round(0.5*(size(patch,1)+1)), round(0.5*(size(patch,2)+1)) ];
    pView = [ 0, 0, 1000 ];
    pCenter = [ center(2), center(1), patch(center(1),center(2)) ];

    [ px py pz] = prepareSurfaceData( 1:size(patch,1), 1:size(patch,2), patch );
    
    px(isnan(pz)) = [];
    py(isnan(pz)) = [];
    pz(isnan(pz)) = [];
    
    points = [ px*10, py*10, pz ];
    covMat = cov( points );
    [ V, D ] = eig( covMat );
    eigValue = diag( D );
    [ a b ] =min( eigValue );
    normal = V(:,b)';
    normal = normal./sqrt(sum(normal.^2));
    
    if dot(normal,(pView-pCenter)) < 0
        normal = -normal;
    end
        
    
    
    