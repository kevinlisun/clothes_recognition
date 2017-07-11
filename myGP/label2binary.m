function [ Y ] = label2binary(Y, c, opt)
    
if nargin < 2
    labels = unique(Y);
    c = length(labels);
    opt = 'vec';
elseif nargin < 3
    labels = 1:c;
    opt = 'vec';
else
    labels = 1:c;
end

n = length(Y);

Ybin = zeros(n,c);

for i = 1:c
    Ybin(Y==labels(i),i) = 1;
end
    

if strcmp(opt,'vec') 
    Y = Ybin(:);
elseif strcmp(opt,'mat')
    Y = Ybin;
else
    disp('ERROR: option cannot be recognized!');
end
