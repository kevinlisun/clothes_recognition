%This is a simple demonstration of the approximate method for GP based
%classification over multiple classes which is presented in
%
% Girolami, M., Rogers, S., 
% Variational Bayesian Multinomial Probit Regression with 
% Gaussian Process Priors. in Press, Neural Computation, 2006.
% Preprint and code available online at 
% http://www.dcs.gla.ac.uk/people/personal/girolami/pubs_2005/VBGP/index.htm 
% and http://www.gaussianprocess.org/

%
% Samples of 2-D data points drawn from three nonlinearly separable
% classes which take the form of two annular rings and one zero-centered
% Gaussian are used in this little illustrative example. In addition to the
% two features required to discriminate betwen the classes a further eight
% noise features are added to demonstrate the posterior mean estimation of
% the hyper-parameters of the covariance function used.

%Generate samples from the three classes for posterior estimation
Ntrain = 500;
Ntest = 5000;
[X,t]=generate_multiclass_toy_data_Plus_Noise(Ntrain);

%Generate samples as an independent test set to assess out-of-sample
%prediction error and predictive likelihoods.
[X_t,t_t]=generate_multiclass_toy_data_Plus_Noise(Ntest);

plot(X_t(find(t_t==1),1),X_t(find(t_t==1),2),'.');
hold on
plot(X_t(find(t_t==2),1),X_t(find(t_t==2),2),'r.');
plot(X_t(find(t_t==3),1),X_t(find(t_t==3),2),'g.');
fprintf('\n\n\nSample data & classes, grab a coffee & hit any key to continue\n\n\n');
hold off;
pause
fprintf('There are ten features in the data but only two\n');
fprintf('are predictive of the target classes, you should see\n');
fprintf('the posterior mean of the covariance function\n');
fprintf('parameters (length scale of Gaussian function)\n');
fprintf('reflect this with all noise feature values decaying\n');
fprintf('to negligble values\n\n\n');

%Randomly initialise the covariance function hyperparameter values
theta = rand(1,10);

%Some arguments to be passed to the main script
theta_estimate = 1;             % Turn - on hyper-parameter inference
Nos_Its = 50;                   % Maximum number of variational EM steps
Kernel_Type = 'gauss';          % Covariance function type for example
Poly_Kernel_Power = 1;          % Parameter value if using Polynomial kernel
Thresh = 1e-6;                  % Iteration threshold on the marginal likelihood

%Main script
[TE, PL, LB] = VarMultProbRegGP(X, t, X_t, t_t,...
                                theta, theta_estimate,... 
                                Nos_Its, Kernel_Type,...
                                Poly_Kernel_Power, Thresh);

