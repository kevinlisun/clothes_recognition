function [ cov ] = computeMultiClassCov(X1, X2, para)

kernel = para.kernel;
c = para.c;

Kci = computeCov(X1, X2, para);

Kc = {Kci};
Kc = repmat(Kc, [c,1]);
    
K = constructBlockDiag(Kc);

cov.K = K;
cov.Kc = Kc;
