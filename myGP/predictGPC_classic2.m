function [ y prob fm ] = predictGPC_classic2(hyp, para, X, Y, model, x)

K = model.K;
W = model.W;
f = model.f;
Pi = model.Pi;
TT = model.TT;

n = length(Y);
c = para.c; 
kernel = para.kernel;

[ Ybin ] = label2binary(Y);

y = zeros(size(x,1), 1);
fm = zeros(size(x,1), c);
prob = zeros(size(x,1), c);

for i = 1:size(x,1)
    Mu = zeros(1,c);
    Cov = zeros(c,c);
    
    disp(['predicting the ', num2str(i),'th of ', num2str(size(x,1)), ' testing example ...']);
    index = repmat(1:c, [n 1]);
    
    for ci = 1:c
        xi = x(i,:);
        kc = feval(kernel, hyp, X, xi);
        %kc = computeCov(X, xi, para);
        Kc{ci} = kc;
        yc = Ybin(index == ci);
        pic = Pi(index == ci);
        
        Mu(ci) = kc' * (yc - pic); 
    end
     
    Q = constructBlockDiag(Kc);
    
    Cov = eye(c) * feval(kernel, hyp, xi, xi) - Q' * inv(K + inv(W+10e-8*eye(size(W)))) * Q;
    %%-----------------fast------------------%%
% %     D = diag(Pi); 
% %     R = inv(D) * TT;
% %     E = D^(0.5) * inv(eye(size(K)) + D^(0.5)*K*D^(0.5)) *  D^(0.5);
% %     KWinv_inv = E - E * R * inv(R'*E*R) * R' * E;
% %     Cov = eye(c) * computeCov(xi, xi, para) - Q' * KWinv_inv * Q;
    %------------------------------------------
    
    % get the probility estimation from sampling
    S = para.S;
    fs = mgd(S, c, Mu, Cov);
    fm(i,:) = Mu;
    
    fs = exp(fs);
    p = fs ./ repmat(sum(fs,2),[1,c]);
    p = sum(p,1) / S;
    prob(i,:) = p;
    
    [ tmp y(i) ] = max(p);
end
    
if para.flag
    figure(2)
    ax1 = subplot(2,2,2);
    title('the prediction labels');
    [ ybin ] = label2binary(y, c);
    ybin = reshape(ybin, size(prob));
    
    imagesc(ybin);colormap(ax1, gray);
    
    ax2 = subplot(2,2,3);
    title('the full prediction probalities');
    imagesc(prob); colormap(ax2, gray);
end
%% 

% % entropy = sum(prob.*log(prob),2);
max_prob = max(prob, [], 2);

if para.flag
    subplot(2,2,4)
    title('the confidence of prediction');
    color = [ 'r', 'b', 'k', 'g', 'y' ];
    marker = [ '+', 'x', '*', 'o', '^' ];
    for ci = 1:c
        plot(find(y==ci), max_prob(y==ci), [color(ci),marker(ci)]);
        hold on;
    end
    plot(1:length(y), 0.25 * ones(size(y)));
    hold off;
end
        

