function [ meanf covf fnew_2 ] = binaryLaplaceApproximation(X, x, Y, func_k)
    
    f = rand(size(X,1),1);
    
    maxIter = 10000;
    thres = 1e-12;
    
    for i = 1:maxIter
        % pi is p(yi=1|fi)
        pi = sigmod(f);
        % t = (y+1)/2
        t = (Y+1) / 2;
        
        % the first order drivative of p(y,f) is ti-pi
        tlogpY_f = t - pi;
        % the second order drivative of p(y,f) is -pi(1-pi)
        ttlogpY_f = -(-pi.*(1-pi));
        W  = diag(ttlogpY_f);
        
        [ K11 ] = computeCov( X, X, func_k );
        [ K21 ] = computeCov( x, X, func_k );
        
        fnew_1 = K11 * inv(eye(size(K11)) + W * K11) * (W * f + tlogpY_f);
        fnew_2 = K21 * K11 * fnew_1;
        
        error = max(abs(f-fnew_1));
        if error <= thres
            meanf = f;
            covf = inv(inv(K11) + W);
            break;
        else
            f = fnew_1;
            disp(['error at iter ', num2str(i), ' is: ', num2str(error)]);
        end
    end
        
        