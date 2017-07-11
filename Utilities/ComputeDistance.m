function [ distanceMat ] = ComputeDistance( inst_1, inst_2 )

num_inst1 = size(inst_1,1);
num_inst2 = size(inst_2,1);
zz1 = sum(inst_1.^2,2);
zz2 = sum(inst_2.^2,2);
distanceMat = sqrt(repmat(zz1,[1,num_inst2]) + repmat(zz2',[num_inst1,1]) -2*inst_1*inst_2');