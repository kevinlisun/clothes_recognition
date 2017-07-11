function [ F f ] = objectivefunc(hyp)

    global logML;
    global marker;
    
    load('parameters.mat');
    
    [ K ] = covMultiClass(hyp, para, X, []);
    [ model ] = LaplaceApproximation(hyp, para, K, X, y);
    
    if isempty(model)
        F = 1e3;
        f = zeros(size(hyp));
        return;
    end
    
    F = logMarginalLikelihood(hyp, para, model);
    
    logML = [ logML, F ];
    
    figure(1);
    subplot(1,3,1);
    plot(1:length(hyp), exp(hyp), 'xb', 'MarkerSize', 12, 'LineWidth', 2);
    title('hyper-paramethers');

    
    figure(1)
    subplot(1,3,2);
    hold on;
    if length(logML) > 1
        plot(length(logML)-1:length(logML), -logML(end-1:end), marker, 'MarkerSize', 12, 'LineWidth', 2);
    else
        plot(1:length(logML), -logML, marker, 'MarkerSize', 12, 'LineWidth', 2);
    end
    title('The Log Marignal Likelihood');

    
    % caculate gridient
    if nargout > 1
        f = logMarginalLikelihood(hyp, para, model, []);
        figure(1);
        subplot(1,3,3);
        axis([0 4 -100 100]);
        plot(1:length(f), f, 'r^', 'MarkerSize', 12, 'LineWidth', 2);
        title('Gradient');
        pause(0.01);
    end
    
