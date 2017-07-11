clear all
clc

knotVec = [  0 0 0 1 2 2 2  ];
knotVec = knotVec./max(knotVec);

n = 4;
m = 4;

patch = normrnd(100,0.2,[8 8]);

surf(patch);

r = size(patch,1);
s = size(patch,2);

[ x y z ] = prepareSurfaceData( 1:r, 1:s, patch );


D = zeros(r*s,3);
D(:,1) = x;
D(:,2) = y;
D(:,3) = z;

%% transform D(x,y,z) to (u,w) paramenters
% u refers x, and w refers y

u = zeros(r,r);
w = zeros(s,r);

u(:,1) = 0;

for i = 1:s
    lower = chordLength( patch(i,:), r );
    for j = 2:r
        upper = chordLength( patch(i,:), j );
        u(i,j) = upper/lower;
    end
end

w(1,:) = 0;

for j = 1:r
    lower = chordLength( patch(:,j), s );
    for i = 2:s
        upper = chordLength( patch(:,j), i );
        w(i,j) = upper/lower;
    end
end


C = zeros(r*s,n*m);

for i = 1:r
    for j = 1:s
        for p = 1:n
            for q = 1:m
                C(((i-1)*j+i),((p-1)*q+p)) = ComputeBasisFunction( knotVec, 3, p, u(i,j) ) * ComputeBasisFunction( knotVec, 3, q, w(i,j) );
            end
        end
    end
end

B = inv(C'*C)*C'*D; 
