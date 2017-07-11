function [ newX, newY, newZ ] = Rotate2PCAaxis( X, Y, Z, viewPoint )


    figure;
    plot3(X,Y,Z,'+b');
    hold on;
    PlotPCA( X, Y, Z );
    hold on;
      
    size_row = size(X,1);
    size_col = size(X,2);

    %% rotate the clothes normal to z axis
    k = min(1000000,length(X));
    samples_index = randsample(length(X),k);
    sampleX = X(samples_index);
    sampleY = Y(samples_index);
    sampleZ = Z(samples_index);
   
    center = [ round(sum(X)/length(X)), round(sum(Y)/length(Y)) ];
    viewPoint = viewPoint;
    
    pCenter = [ center(1), center(2), img(center(2),center(1)) ];

    samples = [ sampleX, sampleY, sampleZ ];
    covMat = cov( samples );
    [ V, D ] = eig( covMat );
    eigValue = diag( D );
    [ a b ] =sort( eigValue, 'ascend' );
    orien_z = V(:,b(1))';
    orien_z = orien_z./sqrt(sum(orien_z.^2));
    
    if dot(orien_z,(viewPoint-pCenter)) < 0
        orien_z = -orien_z;
    end
    
    target_z = [ 0, 0, 1 ];
    
    rotateVec = cross( orien_z, target_z );
    rotateVec = rotateVec./sqrt(sum(rotateVec.^2));
    
    x = rotateVec(1); y = rotateVec(2); z = rotateVec(3);
    theta_z = acos( dot(orien_z, target_z ) / ( sqrt(dot(orien_z,orien_z))*sqrt(dot(target_z,target_z)) ) );
    theta_z = -theta_z;
    M_V_theta_z = [ cos(theta_z)+(1-cos(theta_z))*x^2, (1-cos(theta_z))*x*y-sin(theta_z)*z, (1-cos(theta_z))*x*z+sin(theta_z)*y;...
                               (1-cos(theta_z))*y*x+sin(theta_z)*z, cos(theta_z)+(1-cos(theta_z))*y^2, (1-cos(theta_z))*y*z-sin(theta_z)*x;...
                               (1-cos(theta_z))*z*x-sin(theta_z)*y, (1-cos(theta_z))*z*y+sin(theta_z)*x, cos(theta_z)+(1-cos(theta_z))*z^2; ];
    
    [newXYZ] = [X,Y,Z]*M_V_theta_z;
  
    X = newXYZ(:,1);
    Y = newXYZ(:,2);
    Z = newXYZ(:,3);

    %%
    
    
    %% then rotate the first/second principal direction to x/y axis
    k = min(1000000,length(X));
    samples_index = randsample(length(X),k);
    sampleX = X(samples_index);
    sampleY = Y(samples_index);
    sampleZ = Z(samples_index);

    samples = [ sampleX, sampleY, sampleZ ];
    covMat = cov( samples );
    [ V, D ] = eig( covMat );
    eigValue = diag( D );
    [ a b ] =sort( eigValue, 'ascend' );
    orien_x = V(:,b(3))';
    orien_x = orien_x./sqrt(sum(orien_x.^2));
    
    target_x = [ 1, 0, 0 ];
    
    rotateVec = cross( orien_x, target_x );
    rotateVec = rotateVec./sqrt(sum(rotateVec.^2));
    
    x = rotateVec(1); y = rotateVec(2); z = rotateVec(3);
    theta_x = acos( dot(orien_x, target_x ) / ( sqrt(dot(orien_x,orien_x))*sqrt(dot(target_x,target_x)) ) );
    theta_x = -theta_x;
    M_V_theta_x = [ cos(theta_x)+(1-cos(theta_x))*x^2, (1-cos(theta_x))*x*y-sin(theta_x)*z, (1-cos(theta_x))*x*z+sin(theta_x)*y;...
                               (1-cos(theta_x))*y*x+sin(theta_x)*z, cos(theta_x)+(1-cos(theta_x))*y^2, (1-cos(theta_x))*y*z-sin(theta_x)*x;...
                               (1-cos(theta_x))*z*x-sin(theta_x)*y, (1-cos(theta_x))*z*y+sin(theta_x)*x, cos(theta_x)+(1-cos(theta_x))*z^2; ];
    
    [newXYZ] = [X,Y,Z]*M_V_theta_x;
  
    newX = newXYZ(:,1);
    newY = newXYZ(:,2);
    newZ = newXYZ(:,3);
    
    plot3( newX, newY, newZ,'+g');
    hold on;
    PlotPCA( newX, newY, newZ );
    hold on;
   
    %%
    
    
  
   
    
    
    
    