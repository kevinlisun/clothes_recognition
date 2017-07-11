close
clear
clc

load 'matlab.mat'

group_num = 5;
num = 20;

C = [];
G = [];

for i = 1:num
    if i == 1
        c = 1;
    else
        c = c * 1.5;
    end
    C = [ C, c ];
end

for i = 1:num
    if i == 1
        g = 1;
    else
        g = g * 1.5;
    end
    G = [ G, g ];
end

Accuracy = zeros(length(C),length(G));

for i = 1:length(C)
    for j = 1:length(G)
        
        c = C(i);
        g = G(j);
        
        disp(['C is: ',num2str(c),' gamma is: ',num2str(g)]);
        
        svm_opt = ['-t 2 -c ',num2str(c),' -g ',num2str(g)];
        
        accuracy = zeros(1,group_num);
        for k = 1:group_num
            [ result ] = OneAgainstAllValidification( Instance, Label1, ClothesID, 'SVM-1vs1', svm_opt );
        end
        Accuracy(i,j) = result.accuracy;
        disp(['The average accuracy of OneAgainstAll Cross Validification is: ',num2str(Accuracy(i,j)),'.']);
    end
end

figure
imagesc(Accuracy)

[ a b ] = max(Accuracy);
[ c d ] = max(a);

maxRow = b(d)
maxCol = d

maxC = C(maxRow)
maxG = G(maxCol)