clear
close all
clc

kernel = 2
sigma = 1e-1
flag = true

load('processed_data_norm.mat');

X = []; Y = [];

fold = 5
test = randi(fold,1)

for i = 1:fold
    if i == test
        x = Instance(test:fold:end, :);
        y = Label(test:fold:end, :);
        continue;
    end
    Xi = Instance(i:fold:end, :);
    Yi = Label(i:fold:end, :);
    X = [X;Xi];
    Y = [Y;Yi];
end

n = length(Y);
labels = unique(Y);
c = length(labels);

%%  set the parameters
para.flag = flag;
para.kernel = kernel;
para.sigma = sigma;
para.n = n;
para.c = c;
para.labels = labels;
para.softmax = 'probit'; % logistic or 'probit'
%% 
% convert to standard labels
[X, Y] = prepareTraining(X, Y);

%% The multi-Class Laplace Gaussian Process Classification

% estimate the posterior probility of p(f|X,Y)
[ model ] = multiClassLaplaceApproximation(X, Y, para);
% predictin

[ y_predict prob ] = predictGPC(X, Y, model, x, para);

acc = sum(y==y_predict) / length(y)

ax1 = subplot(2,2,2);
[ ybin ] = label2binary(y);
ybin = reshape(ybin, size(prob));
imagesc(ybin);colormap(ax1, gray);

ax2 = subplot(2,2,3);
imagesc(prob); colormap(ax2, gray);
%% 

entropy = sum(prob.*log(prob),2);
subplot(2,2,4)
color = [ 'r', 'b', 'k', 'g' ];
for ci = 1:c
    plot(find(y==ci), entropy(y==ci), ['--',color(ci),'+']);
    hold on;
end
plot(1:length(y), log(0.25) * ones(size(y)))
