function K = valCovLINiso(hyp, x, z)

    hyp = exp(hyp);
    hyp = 1 / (hyp^(2)) * ones(1,size(x,2));
    
    K = x * diag(hyp) * z';
            

    