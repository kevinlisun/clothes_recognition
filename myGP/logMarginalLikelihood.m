function [ likelihood ] = logMarginalLikelihood(hyp, para, model, i)

if para.c == 2
    X = model.X;
    y = model.y;
    f = model.f;
    K = model.K;
    W = model.W;
    
    Nh = length(hyp);
    n = size(X,1);
    
    sW = sqrt(abs(diag(W))).*sign(diag(W));             % preserve sign in case of negative
    
    if nargin == 3
        likelihood = -(f'*inv(K)*f)/2 - sum(log(1+exp(-y.*f)));
        
        logdet_B = -logdet(eye(size(K)) + sW*sW'.*K) / 2; % - logdetA(K, diag(W))/2;
        
        likelihood = likelihood + logdet_B;
 
    elseif nargin == 4
        
        % compute pi = p(y|fi)
        pi = 1 ./ (1 + exp(-f));
        % t = (y+1)/2
        t = (y+1) / 2;

        B = eye(size(K)) + sqrtm(W) * K * sqrtm(W);
        % caculate inv(inv(K) + W) = inv_invKW
        inv_invKW = K - K * sqrtm(W) * inv(B) * sqrt(W) * K;
        % caculate inv(inv(W)+K) = inv_KinvW
        inv_KinvW = sqrtm(W) * inv(B) * sqrtm(W);
        
        %----------------------------------------------
        % dpif3 is d^3 log p(y|f)/ d f^3
        dpif3 = 2*pi.^3 -3*pi.^2 + pi;
        % logq_df is d log q(y|X,theta) / d f
        logq_df = -0.5*diag(inv_invKW) .* dpif3;
        % df is df/d thetai, dpif is d log p(y|f) /d theta
        dpif = t - pi;
        
        dK = zeros(size(K));
        dK_j = zeros(size(K));
        df = zeros(size(f));
        
        if isempty(i)
            
            Ncore = 12;
            
            if Nh < Ncore
                % do not active parallel
                logq_explict = zeros(1,Nh);
                logq_implict = zeros(1, Nh);
                for j = 1:Nh
                    dK_j = feval(kernel, hyp, X, [], j);
                    logq_explict(1,j) = 0.5 * f' * inv(K) * dK_j * inv(K) * f - 0.5*trace(inv_KinvW*dK_j);
                    
                    df = inv(eye(n)+K*W) * dK_j * dpif;
                    logq_implict(1,j) = sum(logq_df.*df);
                end
            else
                % using parallel
                logq_explict = cell(Ncore,1);
                logq_implict = cell(Ncore,1);
                batch_list = cell(Ncore,1);
                
                for j = 1:Ncore
                    batch_list{j} = j:Ncore:Nh;
                    logq_explict{j} = zeros(1,Nh);
                    logq_implict{j} = zeros(1,Nh);
                end
                
                parfor p = 1:Ncore
                    tmp_list = batch_list{p};
                    tmp_logq_explict = zeros(1,Nh);
                    tmp_logq_implict = zeros(1,Nh);
                    
                    for j = 1:length(tmp_list)
                        
                        dK_j = covMultiClass(hyp, para, X, [], tmp_list(j));
                        tmp_logq_explict(1,tmp_list(j)) = 0.5 * f' * inv(K) * dK_j * inv(K) * f - 0.5 * trace(inv_KinvW * dK_j);
                        
                        df = inv(eye(n)+K*W) * dK_j * dpif;
                        tmp_logq_implict(1,tmp_list(j)) = sum(logq_df.*df);                  
                    end
                    
                    logq_explict{p} = tmp_logq_explict;
                    logq_implict{p} = tmp_logq_implict;
                end
                
                logq_explict = sum(cell2mat(logq_explict),1);
                logq_implict = sum(cell2mat(logq_implict),1);
            end
        else
            % only caculate the partial derivative on dimention i
            dK = covMultiClass(hyp, para, X, [], i);
            logq_explict = 0.5*f' * inv(K) * dK * inv(K) * f - 0.5 * trace(inv_KinvW * dK);
            
            df = inv(eye(n)+K*W) * dK * dpif;
            logq_implict = sum(logq_df.*df);
        end
        
        % here likelihood is the derivative of 'likelihood'
        likelihood = logq_explict + logq_implict;
    else
        disp('ERROR: Too many input variables!');
        disp('[ likelihood ] = logMarginalLikelihood(hyp, para, y, f, K, W, i)');
    end
end
    

if para.c > 2
    X = model.X;
    y = model.y;
    f = model.f;
    K = model.K;
    W = model.W;
    TT = model.TT;
    
    Nh = length(hyp);
    n = size(X,1);
    c = para.c;
    sW = sqrt(abs(diag(W))).*sign(diag(W));             % preserve sign in case of negative
    
    if size(y,1) ~= size(f,1)
        [ y ] = label2binary(y);
    end
    
    if nargin == 3
        ft = reshape(f, [n,c]);
        likelihood = -(f'*invBlockDiag(K,c)*f)./2 + y'*f - sum(log(sum(exp(ft),2)),1);
        
        logdet_B = -logdet(eye(size(K)) + sW*sW'.*K) ./ 2; % - logdetA(K, diag(W))/2;
        
        likelihood = likelihood + logdet_B;
    elseif nargin == 4
        
        % compute pi = p(y|fi)
        ft = reshape(f, [n,c]);
        ft = exp(ft);
        pi = ft ./ repmat(sum(ft,2),[1,c]);
        pi = pi(:);
        
        % compute inv_KinvW = inv(K+inv(W))
        D = diag(pi);
        R = invBlockDiag(D,c) * TT;
        E = diag(sqrtm(D)) * diag(sqrtm(D))' .* invBlockDiag(eye(size(K)) + sqrtm(D)*K*sqrtm(D), c);
        inv_KinvW = E - E * R * inv(R'*E*R) * R' * E;
        
        %----------------------------------------------
        
        % inv(inv(K)+W)
        inv_invKW = K - K * inv_KinvW * K;
        
% % %         % dpif3 is d^3 log p(y|f)/ d f^3
% % %         dpif3 = (2*pi-1) .* (pi - pi.^2);
% % %         % logq_df is d log q(y|X,theta) / d f
% % %         logq_df = -0.5 .* diag(inv_invKW) .* dpif3;
        
        logq_df = zeros(n*c,1);
        
        for j = 1:n
            for cj = 1:c
                logq_df((cj-1)*n+j) =  -0.5 * trace(inv_invKW * get_dWfic(W, pi, n, c, j, cj));
            end
        end
        
        % df is df/d thetai, dpif is d log p(y|f) /d f
        dpif = y - pi;
        
        dK = zeros(size(K));
        dK_j = zeros(size(K));
        df = zeros(size(f));
        
        if isempty(i)
            
            Ncore = 12;
            
            if Nh < Ncore
                % do not active parallel
                logq_explict = zeros(1,Nh);
                logq_implict = zeros(1, Nh);
                for j = 1:Nh
                    dK_j = covMultiClass(hyp, para, X, [], j);
                    logq_explict(1,j) = 0.5*f'*invBlockDiag(K,c)*dK_j*invBlockDiag(K,c)*f - 0.5*trace(inv_KinvW*dK_j);
                    
                    df = inv(eye(n*c)+K*W) * dK_j * dpif;
                    logq_implict(1,j) = sum(logq_df.*df);
                end
            else
                % using parallel
                logq_explict = cell(Ncore,1);
                logq_implict = cell(Ncore,1);
                batch_list = cell(Ncore,1);
                
                for j = 1:Ncore
                    batch_list{j} = j:Ncore:Nh;
                    logq_explict{j} = zeros(1,Nh);
                    logq_implict{j} = zeros(1,Nh);
                end
                
                parfor p = 1:Ncore
                    tmp_list = batch_list{p};
                    tmp_logq_explict = zeros(1,Nh);
                    tmp_logq_implict = zeros(1,Nh);
                    
                    for j = 1:length(tmp_list)
                        
                        dK_j = covMultiClass(hyp, para, X, [], tmp_list(j));
                        tmp_logq_explict(1,tmp_list(j)) = 0.5*f'*invBlockDiag(K,c)*dK_j*invBlockDiag(K,c)*f - 0.5*trace(inv_KinvW*dK_j);
                        
                        df = inv(eye(n*c)+K*W) * dK_j * dpif;
                        tmp_logq_implict(1,tmp_list(j)) = sum(logq_df.*df);
                        
                    end
                    
                    logq_explict{p} = tmp_logq_explict;
                    logq_implict{p} = tmp_logq_implict;
                end
                
                logq_explict = sum(cell2mat(logq_explict),1);
                logq_implict = sum(cell2mat(logq_implict),1);
            end
        else
            % only caculate the partial derivative on dimention i
            dK = covMultiClass(hyp, para, X, [], i);
            logq_explict = 0.5*f'*invBlockDiag(K,c)*dK*invBlockDiag(K,c)*f - 0.5*trace(inv_KinvW*dK);
            
            df = inv(eye(n*c)+K*W) * dK * dpif;
           
            logq_implict = sum(logq_df.*df);
        end
        
        % here likelihood is the derivative of 'likelihood'
        likelihood = logq_explict + logq_implict;
    else
        disp('ERROR: Too many input variables!');
        disp('[ likelihood ] = logMarginalLikelihood(hyp, para, y, f, K, W, i)');
    end
end

% output the -log p(y|X,theta) or - 1st order deritive for minimizing
likelihood = likelihood * -1;