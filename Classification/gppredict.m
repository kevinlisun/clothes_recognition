function [ predict_label prob ] = gppredict( testInst, testLabel, model )

disp('gp predicting... ')
[ testInst label norm ] = prepareData( double(testInst), ones(size(testInst,1),1), model.norm );

meanfunc = model.meanfunc;
covfunc = model.covfunc;
likfunc = model.likfunc;
instances = model.instances;
stdclasses = model.stdclasses;
classes = model.classes;
hyp = model.hyp;

disp('[ymu ys2 fmu fs2] = gp(hyp, @infEP, meanfunc, covfunc, likfunc, x, y, t, ones(n, 1));')
[ ymu ys2 fmu fs2 ] = gp( hyp, @infEP, meanfunc, covfunc, likfunc, instances, stdclasses, testInst, testLabel );
prob = ymu;

predict_label = zeros(size(ymu));
predict_label(ymu<=0) = classes(1);
predict_label(ymu>0) = classes(2);
    
    