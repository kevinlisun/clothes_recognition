function [ inst2 ] = l2norm( inst1 )

    inst2 = inst1 / sqrt( sum( inst1.^2 ) );