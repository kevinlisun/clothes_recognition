function [ likelihood ] = logMarginalLikelihood2(hyp, para, model, i)

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
    likelihood = -(f'*invBlockDiag(K,c)*f)/2 + y'*f - sum(log(sum(exp(ft),2)),1);
    
    logdet_B = -logdet(eye(size(K)) + sW*sW'.*K) / 2; % - logdetA(K, diag(W))/2;
    
    likelihood = likelihood + logdet_B;
elseif nargin == 4
    if isempty(i) % caculate the partical derivative on all dimentions of hyper-parameters
        dK = zeros(size(K,1),size(K,2),Nh);
        for j = 1:Nh
            dK(:,:,j) = covMultiClass(hyp, para, X, [], j);
        end
    else % only caculate the partial derivative on dimention i
        dK = covMultiClass(hyp, para, X, [], i);
    end
    
    % compute pi = p(y|fi)
    ft = reshape(f, [n,c]);
    ft = exp(ft);
    pi = ft ./ repmat(sum(ft,2),[1,c]);
    pi = pi(:);
    
    % compute inv_KinvW = inv(K+inv(W))
    D = diag(pi);
    R = invBlockDiag(D,c) * TT;
    E = diag(D^(0.5)) * diag(D^(0.5))' .* invBlockDiag(eye(size(K)) + D^(0.5)*K*D^(0.5), c);
    inv_KinvW = E - E * R * inv(R'*E*R) * R' * E;
    
    if isempty(i)
        logq_explict = zeros(1,Nh);
        for j = 1:Nh
            logq_explict(1,j) = 0.5*f'*invBlockDiag(K,c)*dK(:,:,j)*invBlockDiag(K,c)*f - 0.5*trace(inv_KinvW*dK(:,:,j));
        end
    else
        logq_explict = 0.5*f'*invBlockDiag(K,c)*dK*invBlockDiag(K,c)*f - 0.5*trace(inv_KinvW*dK);
    end
    
    % dpif3 is d^3 log p(y|f)/ d f^3
    dpif3 = (2*pi-1) .* (pi - pi.^2);
    
    % inv(inv(K)+W)
    inv_invKW = K - K * inv_KinvW * K;
    % logq_df is d log q(y|X,theta) / d f
    logq_df = -0.5*diag(inv_invKW) .* dpif3;
    
    % df is df/d thetai, dpif is d log p(y|f) /d theta
    dpif = y - pi;
    
    if isempty(i)
        logq_implict = zeros(1, Nh);
        for j = 1:Nh
            df = inv(eye(n*c)+K*W) * dK(:,:,j) * dpif;
            logq_implict(1,j) = sum(logq_df.*df);
        end
    else
        df = inv(eye(n*c)+K*W) * dK * dpif;
        logq_implict = sum(logq_df*df);
    end
    % here likelihood is the derivative of 'likelihood'
    likelihood = logq_explict + logq_implict;
else
    disp('ERROR: Too many input variables!');
    disp('[ likelihood ] = logMarginalLikelihood(hyp, para, y, f, K, W, i)');
end

% output the -log p(y|X,theta) or - 1st order deritive for minimizing
likelihood = likelihood * -1;