function [ model ] = LaplaceApproximation(hyp, para, K, X, Y)


maxIter = 50;
thres = 1e-8;


if para.c == 2
    n = length(Y);
    c = para.c;
    
    % intialize latent variables f
    f = zeros(n,1);
    
    for i = 1:maxIter
        % pi is p(yi|fi)
        pi = 1 ./ (1 + exp(-f));
        % t = (y+1)/2
        t = (Y+1) / 2;
        
        % the first order drivative of p(y,f) is ti-pi
        tlogpY_f = t - pi;
        % the second order drivative of p(y,f) is -pi(1-pi)
        ttlogpY_f = -pi.*(1-pi);
        W  = diag(-ttlogpY_f);
        
        %B = eye(size(K)) + sqrtm(W) * K * sqrtm(W);
        % caculate inv(inv(K) + W) = inv_invKW
        %inv_invKW = K - K * sqrtm(W) * inv(B) * sqrt(W) * K;
        
        f_new = K * inv(eye(size(K)) + W*K) * (W * f + tlogpY_f);

        error = max(abs(f-f_new));
        if error <= thres
            model.X = X;
            model.y = Y;
            model.K = K;
            model.f = f;
            model.W = W;
            return;
        else
            f = f_new;
            disp(['error at iter ', num2str(i), ' is: ', num2str(error)]);
        end
    end
end

if para.c > 2
    n = length(Y);
    c = para.c;
    kernel = para.kernel;
    
    [ Ybin ] = label2binary(Y);
    
    % intialize latent variables f
    f = zeros(n,c);
    f = f(:);
    
    for iter = 1:maxIter
        ft = reshape(f, [n, c]);
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
        
        %% stable but slow
        D = diag(Pi);
        R = invBlockDiag(D,c) * TT;
        
        if sum(sum(isnan(D))) > 0 || sum(sum(isinf(D))) > 0
            model = [];
            return;
        end
        P = invBlockDiag(eye(size(K)) + sqrtm(D)*K*sqrtm(D), c);
        if sum(sum(isnan(P))) > 0 || sum(sum(isinf(P))) > 0
            model = [];
            return;
        end
        
        E = sqrtm(D) * P *  sqrtm(D);
        % inv_KinvW is inv(K+inv(W))
        inv_KinvW = E - E * R * inv(R'*E*R) * R' * E; % eq. 3.47 p. 52
        % KinvW_inv is inv(inv(K)+W)
        inv_invKW = K - K * inv_KinvW * K; % eq. 3.45 p. 51
        f_new = inv_invKW * (W*f + Ybin - Pi);
        %% fast
        %     f_new = inv(inv(K) + W) * (W*f + Ybin - Pi);
        %%
        
        error = max(abs(f-f_new));
        if iter == maxIter || error <= thres
            model.X = X;
            model.y = Y;
            model.K = K;
            model.f = f;
            model.Pi = Pi;
            model.W = W;
            model.TT = TT;
            return;
        else
            f = f_new;
            disp(['error at iter ', num2str(iter), ' is: ', num2str(error)]);
            if para.flag
                figure(2);
                axis off
                title('The Latent Variables of GP Multi-class Classification');
                hold on
                subplot(2,2,1)
                imagesc(reshape(f,[n,c]));
                hold off
                pause(.01)
            end
        end
        
    end
end