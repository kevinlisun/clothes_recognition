function [ hyp ] = modelSelection(para, X, y)

figure(1);
title('hyperparameters optimization for model selection');

hyp = para.hyp;

save('parameters.mat', 'para', 'X', 'y');


global logML;
logML = [];

figure(1);
subplot(1,3,2);
clf;

count = 0;

options = optimoptions('fminunc', 'FunValCheck', 'on', 'GradObj', 'on', 'DerivativeCheck', 'off', 'Algorithm', 'quasi-newton', 'Display', 'iter-detailed', 'TolFun', 1e-1, 'TolX', 1e-3, 'MaxFunEvals', 10); %'quasi-newton'

globalmin = realmax;
globalminx = zeros(size(hyp));

global marker;

Markers = {'--og', '--ob'};

space = -2:2;

for i = 1:length(space)
    
    marker = Markers{mod(i,2)+1};
    
    x0 = log( exp(hyp) * power(2,space(i)) );
    
    [ x fval ] = fminunc(@objectivefunc, x0, options);
    
    if fval < globalmin
        globalmin = fval;
        globalminx = x;
    end
end

hyp = globalminx;
disp(['The final optimized hyper-parameters are: ', num2str(exp(hyp))]);
pause(5)


% % [hyp, maxloglikelihood,Iters] = bfgs(hyp, para, X, y, 1e-7, 1e-7, 1e-7*ones(size(hyp)), 100, 'logMarginalLikelihood')
% % 
% % disp(['optimized hyper parameters are :', num2str(hyp)]);  