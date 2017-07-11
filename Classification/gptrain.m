function [ model ] = gptrain( instances, classes )

[ instances stdclasses norm ] = prepareData( instances, classes );

disp('gp training... ')
disp('GP parameters:')
disp('meanfunc = @meanConst; hyp.mean = 0;')
meanfunc = @meanConst; hyp.mean = 0;
disp('covfunc = @covSEard;   hyp.cov = log([1 1 1]);')
covfunc = @covSEard; ell = 1.0; sf = 1.0;  hyp.cov = log([repmat(ell, 1, size(instances,2)), sf]);
disp('likfunc = @likErf;')
likfunc = @likErf;
disp('training... ')

disp('hyp = minimize(hyp, @gp, -40, @infEP, meanfunc, covfunc, likfunc, x, y);')
hyp = minimize(hyp, @gp, 1, @infEP, meanfunc, covfunc, likfunc, instances, stdclasses);

model.meanfunc = meanfunc;
model.covfunc = covfunc;
model.likfunc = likfunc;
model.hyp = hyp;
model.norm = norm;
model.instances = instances;
model.classes = sort(unique(classes),'ascend');
model.stdclasses = stdclasses;