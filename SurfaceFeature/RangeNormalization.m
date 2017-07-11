function [ mat_new, mat_mean, mat_std ] = RangeNormalization( mat )
    
    index = isnan(mat)==0;
    mat_mean = sum(sum(mat(index)))/(size(mat(index),1)*size(mat(index),2));
    mat_std = std2(mat(index));
    mat_new = (mat-mat_mean)/mat_std;