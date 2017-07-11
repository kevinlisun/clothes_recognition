%This computes the posterior mean of the covariance hyperparameters using a
%simple importance sampler

function vp = varphi_update(X,M,psi,Nos_Samps,...
                            Kernel_Type,Poly_Kernel_Power)
V=[];
W=[];
N = size(X,1);

for i=1:Nos_Samps
    varphi = exponential_rnd(psi);
    Varphi = diag(varphi);
    K = create_kernel_no_scaling(X,X,...
                                 Kernel_Type,Varphi,...
                                 Poly_Kernel_Power)  + eye(N);
    ws = prod(diag(exp(-0.5*M'*inv(K)*M)));
    V=[V;varphi];
    W=[W;ws];
end
W=W./sum(W);
vp=sum(V.*repmat(W,1,size(V,2)));

%Little function to generate exponential random variates
function ernd = exponential_rnd(lambda)
ernd = -log(rand(size(lambda)))./lambda;