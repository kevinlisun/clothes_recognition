clear all
clc

knotVec = [  0 0 0 1 2 2 2 ];
knotVec = knotVec./max(knotVec);
order = 3;
n = 4;


D =[ 0 0; 3/2 2; 3 5/2; 9/2 2; 6 0 ];

upper = 0;

for i = 1:size(D,1)
    if i == 1
        t(1) = 0;
    else
        upper = upper + sqrt(sum((D(i,:)-D(i-1,:)).^2));
        t(i) = upper;
    end
end
t = t./upper;

for i = 1:size(D,1)
    for j = 1:n
        N(i,j) = ComputeBasisFunction( knotVec, order, j, t(i) );
    end
end




B = ((inv(N'*N))*N')*D; 
