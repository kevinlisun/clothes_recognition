clear
close all
clc

kernel = 2
numTrain = 20;
numTest = 50;
Dim = 1000;

X = [ 0.5*rand(numTrain,Dim)+0.75; 0.5*rand(numTrain,Dim)-0.25  ];
Y = [ ones(numTrain,1); zeros(numTrain,1) ];
x = [ 0.5*rand(numTest,Dim)+0.75; 0.5*rand(numTest,Dim)-0.25 ];

subplot(1,2,1)
title('generate data');
plot(1:size(X,1), X(:,1), 'b+');
hold on
plot(1:size(X,1), Y(:,1), 'go');

Y(Y==0) = -1;
% estimate the posterior probility of p(f|X,Y)
[ meanf covf fnew_2 ] = laplaceApproximation(X, x, Y, kernel);

[ K11 ] = computeCov( X, X, kernel );
[ K12 ] = computeCov( X, x, kernel );
[ K21 ] = computeCov( x, X, kernel );
[ K22 ] = computeCov( x, x, kernel );

meanftest = K21 * inv(K11) * meanf;
probtest = sigmod(meanftest);

subplot(1,2,2)
title('classification prediction');
plot(1:size(x,1), x(:,1), 'r+');
hold on
plot(1:size(x,1), probtest, 'ko');