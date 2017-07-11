function [K] = multiClassMatricesSum(Kc)
% n is the amount of all instances
% c is the amount of classes
% Kc is a cell array, Kc{i} is the matric for class i
c = length(Kc);
K = zeros(size(Kc{1}));

for i = 1:c
    Kci = Kc{i};
    K = K + Kci;
end