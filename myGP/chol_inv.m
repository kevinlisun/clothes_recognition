function [invM] = chol_inv(M)

L = chol(M, 'lower');
invM = inv(L)' * inv(L);