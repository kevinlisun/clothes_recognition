%This function computes the mean of the truncated Gaussian as detailed in
%the paper equations (5) & (6).

function [tm,z] = tmean(m, indexMax, Nsamps)

K = size(m,1);
u = randn(Nsamps,1);

t = m(indexMax).*ones(K,1) - m;
tr = t;
t(indexMax)=[];

s = repmat(u,1,K-1) + repmat(t,1,Nsamps)';
z = mean(prod(safenormcdf(s'),1) );

for r = 1:K
    sr = repmat(u,1,K) + repmat(tr,1,Nsamps)';
    sr(:,[r indexMax]) = [];
    nr = mean(safenormpdf(u' + m(indexMax)...
                             - m(r)).*prod(safenormcdf(sr'),1) );
    if r == indexMax
        tm(r)=0;
    else
        tm(r) = m(r) - nr/z;
    end
end
tm(indexMax) = sum(m) - sum(tm);
tm = tm';
%functions to avoid numerical problems
%should really make this global as they are
%used by a couple of functions
function c = safenormcdf(x)
thresh=-10;
x(find(x<thresh))=thresh;
c=normcdfM(x);

function c = safenormpdf(x)
thresh=35;
x(find(x<-thresh))=-thresh;
x(find(x>thresh))=thresh;
c=normpdfM(x);

