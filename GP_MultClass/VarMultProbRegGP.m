%This is a very preliminary demonstration implementation of the GP 
%multiclass classification method detailed in
%
%Girolami, M., Rogers, S., 
%Variational Bayesian Multinomial Probit Regression with 
%Gaussian Process Priors. in Press, Neural Computation, 2006.
%Preprint and code available online at 
%http://www.dcs.gla.ac.uk/people/personal/girolami/pubs_2005/VBGP/index.htm 
%and http://www.gaussianprocess.org/ 

%31 July 2006 - Fixed small MATLAB typo in predictive likelihood 

function [predictL, Test_Err, PL, LOWER_BOUND] = ...
          VarMultProbRegGP(X,t,X_test,t_test,...
                           theta,theta_estimate,Nos_Its,Kernel_Type,...
                           Poly_Kernel_Power,Thresh)

                            
%Arguments Passed
% X - Feature matrix for parameter 'estimation' - of dimension N x D
% t - The corresponing target values - class labels
% X_test - Feature matrix to compute out-of-sample (test) prediction errors
% and likelihoods
%
% t_test - Corresponding target values for test data
% theta - The covariance function parameters - e.g. scaling
% coefficients for each dimension
%
% theta_estimate = 1 - if covariance parameter estimation switched on - 0
% if switched off
%
% Nos_Its - the maximum number of variational EM steps to take
% Kernel_Type - Select from Gaussian, Polynomial or Linear Inner product
% Poly_Kernel_Power - Power of polynomial kernel if used
% Thresh - Convergence threshold on marginal likelihood lower-bound
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SMALL_NOS = 1e-10;          % A small number used to prevent 
                            %numerical problems

Nos_Samps_TG = 1000;        % The number of samples used in obtaining 
                            % mean of truncated Gaussian  

Nos_Samps_IS = 1000;        % The number of samples used in 
                            % the importance sampler

sigma = 1e-3;               % The location and scale parameters of the 
                            % Gamma prior over covaraince params
tau = 1e-6;

C = max(t);                 % Identify the number of classes
[N, D] = size(X);           % Get number of samples and dimension of data
Y=randn(N,C);               % Randomly initialise the matrix Y (see paper)
M=rand(N,C);                % Randomly initialis the matrix M (see paper)
beta = theta;
Theta = diag(theta);          % Make a diagonal matrix of the covariance 
                              % params for passing to kernel function
psi = ones(1,length(theta));  % Set hyper-params for covariance params 
                              % to one. In this application 
                              % I have used a simple exponential 
                              % distribution over the theta values so 
                              % there is only a mean value required psi.  
In = eye(N);                  % An N X N dimensional identity matrix      
Ic = eye(C);                  % A C x C dimensional identity matrix                      

diff = 1e100;                 % Monitor difference in marginal likelihood  
its = 0;                      % Initiliase iteration number

% Create the covariance (kernel) matrix and add some small jitter on
% diagonal
K = create_kernel_no_scaling(X,X,...
                             Kernel_Type,Theta,...
                             Poly_Kernel_Power) + eye(N)*SMALL_NOS; 

iK = inv(K + In);               %precompute the inverse matrices required 
Ki = K*iK; 

THETA=[];                       %Collect all the posterior mean values of 
                                %the covariance params
LOWER_BOUND=[-1e-3];            %Collect all the values of the lower-bound    
PL=[];                          %Collect all values of the predictive 
                                %likelihood
Test_Err=[];                    %Collect all values of the percentage 
                                %predictions incorrect

%In this implementation a single covariance function is shared across all
%classes, however a more general implementation provides a covariance
%function and associated parameters for each class. Having a shared 
%covariance function across all classes has not appeared to be 
%much of a handicap for many UCI data sets. However for the Forensic
%Glass data (Ripley) prediction errors (computed by 10-fold cross
%validation) tends to be around 30% ~ 34% - but using a covatiance function
%for each class performance improves to around 24% - 25% 10CV errors. This
%seems to accord with what Williams & Barber (1998) noted in their
%experiments.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This is the main loop 
while its < Nos_Its & diff > Thresh    
            its = its + 1;
            
            %Here we update the columns of the M-matrix - equation (8) of
            %the paper
            for k = 1:C
                M(:,k) = Ki*Y(:,k);
            end   
            
            %Here we update the rows of the Y-matrix - equation (5) & (6)
            %of the paper
            
            lower_bound = 0;
            for n=1:N
                [a,z] =  tmean(M(n,:)',t(n),Nos_Samps_TG);
                Y(n,:) = a';
                lower_bound = lower_bound + safelog(z);
            end
            
            %Here we update the posterior mean estimates of the covariance 
            %function parameters and hyper-params
            
            if theta_estimate == 1
                theta = varphi_update(X,M,psi,...
                                      Nos_Samps_IS,Kernel_Type,...
                                      Poly_Kernel_Power);                               
                Theta = diag(theta);
                psi = (sigma+1)./(tau+theta);
                THETA=[THETA;theta];
                
                subplot(221);
                plot(safelog(THETA),'.-');
                title('Covariance Parameters Posterior Mean Values');
                drawnow;
                K = create_kernel_no_scaling(X,X,...
                                             Kernel_Type,Theta,...
                                             Poly_Kernel_Power);
                iK = inv(K + In); 
                Ki = K*iK;
            end
            
            %Here we compute the lower-bound
            lower_bound = lower_bound -0.5*C*trace(K*iK)...
                                      -0.5*sum(diag(M'*inv(K+In)*M)) ... 
                                      -0.5*C*trace(iK)... 
                                      -0.5*C*safelog(abs(det(K )))...
                                      +0.5*C*safelog(abs(det(K*iK)))...
                                      -0.5*N*C*safelog(2*pi)...
                                      +0.5*N*C + 0.5*N*safelog(2*pi);
                
            %This just plots the development of the bound at every
            %iteration
            
            LOWER_BOUND=[LOWER_BOUND;lower_bound]; 
            if its == 2 
                LOWER_BOUND(1) = LOWER_BOUND(2) ;
            end;
            subplot(222)
            plot(LOWER_BOUND);title('Lower Bound');drawnow;
            
            %Monitoring convergence
            diff = abs(100*(lower_bound - LOWER_BOUND(end-1))...
                            /LOWER_BOUND(end-1));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Here we compute the predictive posteriors on the test set and
            %the associated likelihood and test errors - this is computed
            %at each iteration simply to show how test performance develops
            %at each iteration
            
            Ntest = size(X_test,1);     %Number of test points
            %Create test covariance matrices required to obtain predictive
            %mean and variance values
            
            Ktest = create_kernel_no_scaling(X,X_test,...
                                             Kernel_Type,Theta,...
                                             Poly_Kernel_Power);
                                         
            KtestSelf = create_kernel_no_scaling(X_test,X_test,...
                                                 Kernel_Type,Theta,...
                                                 Poly_Kernel_Power);
                                             
            S = (diag(KtestSelf) - diag(Ktest'*iK*Ktest))';
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %This section computes the predictive posteriors as defined in
            %Section 4.5 of the paper. This really should be written as a
            %Mex file for speed due to the loops required in Matlab. Also
            %note that this assumes one covariance function shared across
            %all classes.            
            predictive_likelihood = 0;
            Res=(Y'*iK*Ktest)';
            Ptest = ones(Ntest,C);
            u = randn(Nos_Samps_TG,1);
            for n=1:Ntest
               for i=1:C
                   pp=ones(Nos_Samps_TG,1); 
                   for j=1:C
                        if j ~= i
                            pp = pp.*safenormcdf(u + (Res(n,i)  ...
                                                   - Res(n,j))./ ...
                                                   (sqrt(1+S(n)))  );
                        end
                   end
                   Ptest(n,i) = mean(pp);
               end
               Ptest(n,:)=Ptest(n,:)./sum(Ptest(n,:));%JUST IN CASE
               
               %This computes the overall predictive likelihood
               predictive_likelihood = predictive_likelihood...
                                     + safelog(Ptest(n,t_test(n)));
            end
            Ptest=Ptest';
            PL=[PL;predictive_likelihood/Ntest];
            subplot(224)
            plot(PL);title('Predictive Likelihood');drawnow;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Now we compute the 0-1 error loss.
            [a,b]=max(Ptest',[],2);
            
            % get the prediction labels
            predictL = b;
            
            Test_Err=[Test_Err 100*(sum(b ~= t_test))/Ntest];
 
            subplot(223)
            fprintf('%d: Value of Lower-Bound = %f,Prediction Error = %f, Predictive Likelihood = %f\n',... 
                     its, lower_bound,Test_Err(its),predictive_likelihood/Ntest);
            plot((100-Test_Err));title('Out-of-Sample Percent Prediction Correct');drawnow;
            Acc = 100 - Test_Err(its);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%A number of utility functions to prevent numerical problems
function y = safelog(x)
x(find(x<1e-300))=1e-200;
x(find(x>1e300))=1e300;
y=log(x);


function y = safelog2(x)
x(find(x<1e-300))=1e-200;
x(find(x>1e300))=1e300;
y=log2(x);


function c = safenormcdf(x)
thresh=-10;
x(find(x<thresh))=thresh;
c=normcdfM(x);


function c = safenormpdf(x)
thresh=35;
x(find(x<-thresh))=-thresh;
x(find(x>thresh))=thresh;
c=normpdfM(x);
