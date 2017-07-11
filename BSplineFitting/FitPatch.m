function [ obj ] = FitPatch( Patch, knotVec, C )


    XI = Patch(:,:,1);
    YI = Patch(:,:,2);
    patch = Patch(:,:,3);
    
    knotVec = knotVec./max(knotVec);
    order = sum(knotVec==0);
    n = length(knotVec)-order;
    m = length(knotVec)-order;

    r = size(patch,1);
    s = size(patch,2);
    
    nanMap = isnan(patch);

    x = reshape(XI,[r*s,1]);
    y = reshape(YI,[r*s,1]);
    z = reshape(patch,[r*s,1]);
    
    x(isnan(z)) = [];
    y(isnan(z)) = [];
    z(isnan(z)) = [];
%     [ x y z ] = prepareSurfaceData( 1:r, 1:s, patch );
    
    if sum(sum(isnan(patch)==0)) > 0
        patch = griddata( x, y, z, XI, YI, 'nearest' );
        if size(patch,1)*size(patch,2)~=r*s
            obj = [];
            return;
        end
        x = reshape(XI,[r*s,1]);
        y = reshape(YI,[r*s,1]);
        z = reshape(patch,[r*s,1]);
    end

    D = zeros(length(x),3);
    D(:,1) = x;
    D(:,2) = y;
    D(:,3) = z;
    
    %% transform D(x,y,z) to (u,w) paramenters
    % u refers x, and w refers
    % r is the number of rows of patch points, s is the number of colums
    % n is the number of control points, corresponding to y/u/r direction, m is
    % the control points along the x/w/s direction
    if nargin < 3 || size(C,1) ~= r*s
        % compute base function C
        u = zeros(r,s);
        w = zeros(r,s);
        
        u(1,:) = 0;
        
        for i = 1:s
            lower = chordLength( patch(:,i), r );
            for j = 2:r
                upper = chordLength( patch(:,i), j );
                u(j,i) = upper/lower;
                u(j,i) = (j-1)/r;
            end
        end
        
        w(:,1) = 0;
        
        for i = 1:r
            lower = chordLength( patch(i,:), s );
            for j = 2:s
                upper = chordLength( patch(i,:), j );
                w(i,j) = upper/lower;
                w(i,j) = (j-1)/s;
            end
        end
        
        C = GiveMeAGoodName(r,s,n,m,knotVec,order,u,w);
        
        
% %         C = zeros(r*s,n*m);
% %         
% %         for i = 1:r
% %             for j = 1:s
% %                 for p = 1:n
% %                     for q = 1:m
% %                         C(((i-1)*s+j),((p-1)*m+q)) = ComputeBasisFunction( knotVec, order, p, u(i,j) ) * ComputeBasisFunction( knotVec, order, q, w(i,j) );
% %                     end
% %                 end
% %             end
% %         end
    end
    
    B = ((inv(C'*C))*C')*D;
    D2 = C*B;
    
    if sum(sum(nanMap)) > 0
        patch = reshape(D2(:,3),[size(patch,1) size(patch,2)]);
        patch(nanMap==1) = nan;
        nanMap = reshape(nanMap,[r*s 1]);
        D2(nanMap==1,:) = [];
        
        obj.D = D2;
        obj.B = B;
        obj.C = C;
        obj.patch = patch;
        obj.isnan = 1;
        obj.nanMap = nanMap;
        obj.pnum_u = r;
        obj.pnum_w = s;
        obj.bnum_u = n;
        obj.bnum_w = m;
    else
        obj.D = D2;
        obj.B = B;
        obj.C = C;
        obj.patch = reshape(obj.D(:,3),[size(patch,1) size(patch,2)]);
        obj.isnan = 0;
        obj.nanMap = zeros(r,s);
        obj.pnum_u = r;
        obj.pnum_w = s;
        obj.bnum_u = n;
        obj.bnum_w = m;
    end
    

