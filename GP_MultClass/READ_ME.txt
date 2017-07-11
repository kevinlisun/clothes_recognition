The following files provide a Matlab based demonstration of the
GP classifier for multiple classes as detailed in the paper

Girolami, M., Rogers, S., 
Variational Bayesian Multinomial Probit Regression with 
Gaussian Process Priors. in Press, Neural Computation, 2006.

VarMultProbRegGP.m - main calling routine for posterior inference over train & test data
tmean.m - computes truncated mean
normpdfM.m - compute normal pdf
normcdfM.m - compute normal cdf
create_kernel_no_scaling.m - create the covariance matrix
varphi_update.m - computes the poserior mean of covariance params using importance sampler
generate_multiclass_toy_data_Plus_Noise.m - creates toy data for demo
ImpSampDemo.m - runs the classification demo

To run the demo download all files into one directory - start up Matlab,
get yourself a coffee, type ImpSampDemo and the demo should start. 

Mark Girolami PhD
Bioinformatics Research Centre
Department of Computing Science
A416, Fourth Floor, Davidson Building
University of Glasgow
Glasgow G12 8QQ
Scotland UK

Tel : +44 (0)141 330 8628
Fax: +44 (0)141 330 8627

email : girolami@dcs.gla.ac.uk