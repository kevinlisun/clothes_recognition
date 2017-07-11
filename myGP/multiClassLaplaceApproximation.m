function [ model ] = multiClassLaplaceApproximation(X, Y, para)

% compute the covariance
[ cov ] = computeMultiClassCov(X, X, para);
n = para.n;
c = para.c; 
kernel = para.kernel;

K = cov.K;
[ Ybin ] = label2binary(Y);
% intialize latent variables f
f = rand(n,c);
f = f(:);

maxIter = 100;
thres = 2 * 1e-5;

for i = 1:maxIter
    Pi = zeros(n,c);
    ft = reshape(exp(f),[n,c]);
    pi = ft./repmat(sum(ft,2),[1 c]);
    for ci = 1:c
%         ft = f;
%         ft = reshape(ft,[n,c]);
%         ft = exp(ft);
%         ft = ft(:,ci)./sum(ft,2);
%         ft = softmax(ft, para.softmax);
%         pi = ft(:,ci) ./ sum(ft,2);
%         Pi(:,ci) = pi;
        dc = diag(pi(:,c));
        Dc{ci} = dc;
        
        sdc = sqrt(abs(diag(dc))).*sign(diag(dc));% preserve sign in case of negative

        Kc = cov.Kc{ci};
        U = eye(size(Kc)) + sdc*sdc'.*Kc;
        
        L = chol(U);
        
        ec = sqrt(dc) * L' \ (L\sqrt(dc));
        Ec{ci} = ec;
        l = L(:);
        zc = sum(log(diag(L)));
%         zc = sum(log(l(l>=1e-7)));
        Zc{ci} = zc;
    end
    
    % compute Pi and TT with eq 3.34 and 3.38
    Pi = Pi(:);
    TT = stackVerticalMatrices(Dc);
    
    E = constructBlockDiag(Ec);
    M = chol(multiClassMatricesSum(Ec),'lower');
    
    % b = Wf + Y -pi, eq 3.39
    D = constructBlockDiag(Dc);
    B = (D - TT*TT') * f + Ybin - reshape(pi,n*c,1);
    
    C = E*K*B;
    R = repmat(eye(n),[c,1]);
    
    A = B - C + (E*R*M)'\(M\(R'*C));
    
    f_new = K*A;
    
    f_ci = reshape(f,[n,c]);
    likelihood(i) = -0.5*A'*f + Ybin'*f + sum(log(sum(softmax(f_ci, para.softmax),2))) - sum(cell2mat(Zc));
    
    error = max(abs(f-f_new));
    if error <= thres
        model.f = f_new;
        model.Pi = pi;
        model.cov = cov;
        return;
    else
        f = f_new;
        disp(['error at iter ', num2str(i), ' is: ', num2str(error)]);
        disp(['the likelihood at iter ', num2str(i), ' is: ', num2str(likelihood(i))]);
        figure(1)
        subplot(2,2,1)
        imagesc(f_ci);
% %         plot(1:length(f),f,'bo')
        subplot(2,2,2)
        hold on
        plot(1:i,likelihood, '--rs');
        hold off
        pause(.01)
    end
    
end


