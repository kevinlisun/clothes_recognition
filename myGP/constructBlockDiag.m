function [K] = constructBlockDiag(Kc)
% n is the amount of all instances
% c is the amount of classes
% Kc is a cell array, Kc{i} is the matric for class i
c = length(Kc);
[ row col ] = size(Kc{1});
K = zeros(row*c, col*c);

index_row = 1;
index_col = 1;

for i = 1:c
    Kci = Kc{i};
    K(index_row:index_row+row-1, index_col:index_col+col-1) = Kci;
    index_row = index_row + row;
    index_col = index_col + col;
end

