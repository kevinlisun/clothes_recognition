function PlotPCA( X, Y, Z )

            
    size_row = size(X,1);
    size_col = size(X,2);

    %% rotate the clothes normal to z axis
    k = min(100000,0.1*length(X));
    samples_index = randsample(length(X),k);
    sampleX = X(samples_index);
    sampleY = Y(samples_index);
    sampleZ = Z(samples_index);
   
    pCenter = [ mean(Y) mean(X) mean(Z) ];

    samples = [ sampleX, sampleY, sampleZ ];
    covMat = cov( samples );
    [ V, D ] = eig( covMat );
    eigValue = diag( D );
    [ a b ] =sort( eigValue, 'ascend' );
    orien_z = V(:,b(1))';
    orien_y = V(:,b(2))';
    orien_x = V(:,b(3))';
    
    p1 = [pCenter(2) pCenter(1) pCenter(3)];
    p2 = p1 + orien_z*1000;
    arrow3d(p1,p2,15,'cylinder',[0.5,0.5]);
    hold on;
    
    p3 = p1 + orien_y*1000;
    arrow3d(p1,p3,15,'cylinder',[0.5,0.5]);
    hold on;
    
    p4 = p1 + orien_x*1000;
    arrow3d(p1,p4,15,'cylinder',[0.5,0.5]);
    hold on;
    
    