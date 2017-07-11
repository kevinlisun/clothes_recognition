function [ confMax ] = getConfusionMatrix( test_label, predict_label, labelNum )
    
    confMax = zeros(labelNum,labelNum);
    for i = 1:labelNum
        for j = 1:labelNum
            confMax(i,j) = sum(predict_label(find(test_label==i))==j) / sum(test_label==i);
        end
    end