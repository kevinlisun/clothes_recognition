function [ y prob ] = predictGPC(X, Y, model, x, para)


K = model.cov.K;
cov = model.cov;
f = model.f;
Pi = model.Pi;

n = para.n;
c = para.c; 
% K = cov.K;
[ Ybin ] = label2binary(Y);

Pi = zeros(n,c);


ft = reshape(exp(f),[n,c]);
Pi = ft ./ repmat(sum(ft,2),[1 c]);
for ci = 1:c
%     ft = f;
%     ft = reshape(ft,[n,c]);
%     ft = softmax(ft, para.softmax);
%     pi = ft(:,ci) ./ sum(ft,2);
%     Pi(:,ci) = pi;
    dc = diag(Pi(:,ci));
    Dc{ci} = dc;
    
    Kc = cov.Kc{ci};
    
    L = chol(eye(size(Kc)) + sqrt(dc)*Kc*sqrt(dc),'lower');
    
    
    ec = sqrt(dc) * L' \ (L\sqrt(dc));
    Ec{ci} = ec;

end

% compute Pi and TT with eq 3.34 and 3.38
Pi = Pi(:);
TT = stackVerticalMatrices(Dc);

E = constructBlockDiag(Ec);
M = chol(multiClassMatricesSum(Ec), 'lower');
R = eye(n);

prob = zeros(size(x,1), c);
y = zeros(size(x,1), 1);

for i = 1:size(x,1)
    disp(['predicting the ', num2str(i),'th of ', num2str(size(x,1)), ' testing example ...']);
    Mu = zeros(1, c);
    Cov = zeros(c, c);
    
    for ci = 1:c
        index = repmat(1:c,[n,1]);
        index = index(:);
        % kc is the covariance matrix(vector) between x* (testing example) and
        % X of classs ci
        [ kc ] = computeCov(X, x(i,:), para);
        Mu(ci) = (Ybin(index==ci) - Pi(index==ci))' * kc;
        
        B = Ec{ci} * kc;
        C = Ec{ci} * (R * (M' \ (M\(R'*B))));
        
        for cj = 1:c
            Cov(ci,cj) = C' * kc;
        end
        [ kcxx ] = computeCov(x(i,:), x(i,:), para);
        Cov(ci, ci) = Cov(ci, ci) + kcxx -B' * kc;
    end
    S = 1e5;
    fs = mgd(S, c, Mu, Cov);
    fs = exp(fs);
    fs = fs./repmat(sum(fs,2),[1 c]);
%     fs = softmax(fs, para.softmax);
    p = fs;
    p = sum(p,1) / S;
    prob(i,:) = p;
    
    [ tmp y(i) ] = max(p);
end