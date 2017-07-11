clear
close all

dim = 2 % the dimention i want to test

N = 100; F = 5; nClass = 4;
X = 2*rand(N, F)-1;
beta = randn(nClass,F);
eta = X*beta';
lse = logsumexp(eta,2);
prob = bsxfun(@minus, eta, lse);
prob = exp(prob);
[junk,y] = max(prob,[],2);
Ntest = 50; Ntrain = ceil(0.8*N);
idx = randperm(N);
ytrain = y(idx(1:Ntrain)); %ytrain(ytrain==2) = -1;
Xtrain = X(idx(1:Ntrain),:);
ytest = y(idx(N-Ntest+1:end));
Xtest = X(idx(N-Ntest+1:end),:);

kernel = @covSEard

para.kernel = kernel;
para.c = 4;
para.flag = 0;
hyp1 = log([ones(1,5)*5,3]);

[ K ] = covMultiClass(hyp1, para, Xtrain, []);
[ model ] = LaplaceApproximation(hyp1, para, K, Xtrain, ytrain);

F1 = logMarginalLikelihood(hyp1, para, model)

gradient = logMarginalLikelihood(hyp1, para, model, dim)

hyp2 = hyp1;
for i = 1:8
    
    delta = 1 * power(10,-i);
    
    hyp2(dim) = hyp1(dim) + delta;
    
    [ K ] = covMultiClass(hyp2, para, Xtrain, []);
    [ model ] = LaplaceApproximation(hyp2, para, K, Xtrain, ytrain);
    
    F2 = logMarginalLikelihood(hyp2, para, model)
    
    gradient_real = (F2 - F1) / delta
    
    figure(3)
    plot(i, gradient_real, 'bo');
    hold on
    plot(i, gradient, 'r+');
    hold on
    pause(0.2)
    
end

