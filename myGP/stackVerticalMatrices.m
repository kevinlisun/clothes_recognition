function [K] = stackVerticalMatrices(Kc)
% n is the amount of all instances
% c is the amount of classes
% Kc is a cell array, Kc{i} is the matric for class i
c = length(Kc);
if size(Kc) ~= [c,1]
    Kc = reshape(Kc, [c,1]);
end

K = cell2mat(Kc);