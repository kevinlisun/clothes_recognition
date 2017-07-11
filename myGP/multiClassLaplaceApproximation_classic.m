function [ model ] = multiClassLaplaceApproximation_classic(X, Y, para)


% compute the covariance
[ cov ] = computeMultiClassCov(X, X, para);

K = cov.K;
n = length(Y);
c = para.c; 
kernel = para.kernel;

[ Ybin ] = label2binary(Y);

% intialize latent variables f
f = rand(n,c);
f = f(:);

maxIter = 100;
thres = 1e-2;

for iter = 1:maxIter
    ft = reshape(f, [n, c]);
% %     ft = softmax(ft, para.softmax);
    ft = exp(ft);
    Pi = ft ./ repmat(sum(ft,2), [1 c]);
    Pi = Pi(:);
    index = repmat(1:c, [n,1]);
    index = index(:);
    
    for ci = 1:c
        Pic{ci} = diag(Pi(index==ci));
    end
    
    TT = stackVerticalMatrices(Pic);
    W = diag(Pi) - TT*TT';
    
% %     D = diag(Pi);
% %     R = inv(D) * TT;
% %     E = D^(0.5) * inv(eye(size(K)) + D^(0.5)*K*D^(0.5)) *  D^(0.5);
% %     KWinv_inv = E - E * R * inv(R'*E*R) * R' * E;
% %     
% %     KinvW_inv = K - K * KWinv_inv * K;
% %     f_new = KinvW_inv * (W*f + Ybin - Pi);
    f_new = inv(inv(K) + W) * (W*f + Ybin - Pi);
    
    error = max(abs(f-f_new));
    if iter == maxIter || error <= thres
        model.f = f;
        model.cov = cov;
        model.Pi = Pi;
        model.W = W;
        model.TT = TT;
        return;
    else
        f = f_new;
        disp(['error at iter ', num2str(iter), ' is: ', num2str(error)]);
        
        if para.flag
            figure(1)
            subplot(2,2,1)
            title('the latent variables');
            imagesc(reshape(f,[n,c]));
            
            pause(.01)
        end
    end
    
end