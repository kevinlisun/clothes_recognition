function [ weights ] = computeWeigts( post )

kNum = size(post,2);
nNum = size(post,1);

meanN = nNum/kNum;

for i = 1:kNum
    N(i,1) = sum(post(:,i)==1);
end

w = @(n,k) 1/(1+exp(-k*(n-meanN)));

for i = 1:kNum
    weights(1,i) = w(N(i), 0.0005);
end

weights = l1norm(weights) * kNum;